//  ODManager.m
//  ODManager
//
// Copyright (c) 2014 Eldon Ahrold ( https://github.com/eahrold/ODManager )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <OpenDirectory/OpenDirectory.h>
#import "ODManager.h"
#import "ODManagerNode.h"
#import "ODManagerRecord.h"
#import "ODManagerEditor.h"
#import "ODManagerError.h"

NSString* kODMUserRecord;
NSString* kODMGroupRecord;
NSString* kODMPresetRecord;

@interface ODManager () <ODManagerDelegate> {
    ODManagerNode* _nodeManager;
}

@property (readwrite, nonatomic) NSInteger status;
@end

@implementation ODManager {
    NSInteger returnCount;
    NSMutableArray* _queryResults;
    void (^QureyResults)(NSArray* queryResults, NSError* error);
    void (^_QureyReplyBlock)(id queryResults);
}

#pragma mark - Singleton
+ (ODManager*)sharedManager
{
    static dispatch_once_t onceToken;
    static ODManager* shared;
    dispatch_once(&onceToken, ^{
        shared = [[ODManager alloc] init];
    });
    return shared;
}

#pragma mark - Initializers

- (id)initWithDelegate:(id<ODManagerDelegate>)delegate
{
    self = [self init];
    if (self) {
        _delegate = delegate;
        [_delegate didRecieveStatusUpdate:kODMNodeNotSet];
    }
    return self;
}

- (id)initWithServer:(NSString*)server domain:(int)domain
{
    self = [self init];
    if (self) {
        _directoryServer = server;
        _directoryDomain = domain;
        [self getServerNode:nil];
    }
    return self;
}

- (id)initWithServer:(NSString*)server
{
    return [self initWithServer:server domain:kODMDefaultDomain];
}

- (id)initWithDomain:(ODMDirectoryDomains)domain
{
    return [self initWithServer:nil domain:domain];
}

- (id)initWithDefaultDomain
{
    return [self initWithServer:nil domain:kODMDefaultDomain];
}

- (void)dealloc
{
    //    [self removeObserver:self forKeyPath:@"directoryDomain"];
    //    [self removeObserver:self forKeyPath:@"directoryServer"];
}

#pragma mark - Query
#pragma mark-- With Delegate
- (void)userListWithDelegate:(id<ODManagerDelegate>)delegate
{
    [self queryWithDelegate:delegate type:kODRecordTypeUsers];
}

- (void)groupListWithDelegate:(id<ODManagerDelegate>)delegate
{
    [self queryWithDelegate:delegate type:kODRecordTypeGroups];
}

- (void)presetListWithDelegate:(id<ODManagerDelegate>)delegate
{
    [self queryWithDelegate:delegate type:kODRecordTypePresetUsers];
}

- (void)queryWithDelegate:(id<ODManagerDelegate>)delegate type:(NSString*)type
{
    if (!_nodeManager.node) {
        if (![self getServerNode:nil]) {
            return;
        }
    }
    ODManagerRecord* records = [[ODManagerRecord alloc] initWithNode:_nodeManager.node];
    records.delegate = delegate;
    [records asyncQueryWithType:type];
}

#pragma mark-- Async Reply with block
- (void)userListWithBlock:(void (^)(ODUser* user))reply
{
    if (!_nodeManager.node) {
        if (![self getServerNode:nil]) {
            return;
        }
    }

    ODManagerRecord* records = [[ODManagerRecord alloc] initWithNode:_nodeManager.node];
    records.queryReplyBlock = reply;
    [records asyncQueryWithType:kODRecordTypeUsers];
}

#pragma mark-- With Reply Block
- (void)userList:(void (^)(NSArray*))reply
{
    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        reply([self queryListType:kODRecordTypeUsers]);
    }];
}

- (void)groupList:(void (^)(NSArray* array))reply
{
    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        reply([self queryListType:kODRecordTypeGroups]);
    }];
}

- (void)presetList:(void (^)(NSArray* array))reply
{
    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        reply([self queryListType:kODRecordTypePresetUsers]);
    }];
}

- (NSArray*)queryListType:(NSString*)type
{
    if (!_nodeManager.node) {
        if (![self getServerNode:nil]) {
            return nil;
        }
    }
    ODManagerRecord* rg = [[ODManagerRecord alloc] initWithNode:_nodeManager.node];
    return [rg listQueryWithType:type];
}

- (NSArray*)groupMembers:(NSString*)group
{
    if (!_nodeManager.node)
        [self getServerNode:nil];
    return [ODManagerRecord groupMembers:group node:_nodeManager.node];
}

- (NSArray*)avaliableLocalNodes
{
    if (!_nodeManager.node) {
        [self getServerNode:nil];
    }

    if (_nodeManager.node) {
        NSDictionary* dict = [_nodeManager.node nodeDetailsForKeys:nil error:nil];
        return dict[@"dsAttrTypeStandard:CSPSearchPath"];
    }
    return nil;
}

- (BOOL)user:(NSString*)user isMemberOfGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    return [ODManagerRecord user:user isMemberOfGroup:group node:_nodeManager.node error:error];
}

- (ODPreset*)settingsForPreset:(NSString*)preset
{
    return [ODManagerRecord settingsForPrest:preset node:_nodeManager.node];
}

#pragma mark - ODUser / ODGroup Modifiers
#pragma mark Add ODUser
- (BOOL)addUser:(ODUser*)user error:(NSError* __autoreleasing*)error
{
    return [self addUser:user withPreset:nil error:error];
}

- (BOOL)addUser:(ODUser*)user withPreset:(NSString*)preset error:(NSError* __autoreleasing*)error
{
    if (_authenticated || [self authenticate:error] > 0) {
        ODRecordList* list = [ODRecordList new];
        ODManagerEditor* editor = [[ODManagerEditor alloc] initWithNode:_nodeManager.node];
        list.users = @[ user ];
        return [editor addUsers:list withPreset:preset error:error];
    }
    return NO;
}

- (void)addListOfUsers:(ODRecordList*)list reply:(void (^)(NSError*))reply
{
    [self addListOfUsers:list withPreset:nil reply:reply];
}

- (void)addListOfUsers:(ODRecordList*)list withPreset:(NSString*)preset reply:(void (^)(NSError*))reply
{
    NSError* error;
    if (_authenticated || [self authenticate:&error] > 0) {
        NSOperationQueue* userListQueue = [NSOperationQueue new];
        [userListQueue addOperationWithBlock:^{
            /* we use the singleton here so the import can get canceled */
            ODManagerEditor *editor = [ODManagerEditor new];
            editor.delegate=_delegate;
            editor.errorReplyBlock=reply;
            editor.progressUpdateBlock = _userAddedUpdateHandler;
            editor.node=_nodeManager.node;
            editor.continueImport = YES;
            [editor addUsers:list withPreset:preset error:nil];
        }];
    } else {
        reply(error);
    }
}

- (void)addListOfUsers:(ODRecordList*)list progress:(void (^)(NSString*, double))progress reply:(void (^)(NSError*))reply
{
    [self addListOfUsers:list withPreset:nil progress:progress reply:reply];
}

- (void)addListOfUsers:(ODRecordList*)list withPreset:(NSString*)preset progress:(void (^)(NSString*, double))progress reply:(void (^)(NSError*))reply
{
    NSError* error;
    if (_authenticated || [self authenticate:&error] > 0) {
        NSOperationQueue* userListQueue = [NSOperationQueue new];
        [userListQueue addOperationWithBlock:^{
            /* we use the singleton here so the import can get canceled */
            ODManagerEditor *editor = [ODManagerEditor sharedEditor];
            editor.progressUpdateBlock = progress;
            editor.errorReplyBlock=reply;
            editor.node=_nodeManager.node;
            editor.continueImport = YES;
            [editor addUsers:list withPreset:preset error:nil];
        }];
    } else {
        reply(error);
    }
}

- (void)cancelUserImport
{
    [[ODManagerEditor sharedEditor] setContinueImport:NO];
}

#pragma mark Remove Users
- (BOOL)removeUser:(NSString*)user error:(NSError* __autoreleasing*)error
{
    ODRecord* record = [ODManagerRecord getUserRecord:user node:_nodeManager.node error:error];
    return [record deleteRecordAndReturnError:error];
}

- (void)removeUsers:(NSArray*)users reply:(void (^)(NSError* error))reply
{
    NSError* error;
    if (_authenticated || [self authenticate:&error] > 0) {
        NSOperationQueue* userListQueue = [NSOperationQueue new];
        [userListQueue addOperationWithBlock:^{
            NSError *replyError;
            /* we use the singleton here so the import can get canceled */
            ODManagerEditor *editor = [ODManagerEditor sharedEditor];
            editor.node = _nodeManager.node;
            editor.delegate=_delegate;
            editor.errorReplyBlock=reply;
            editor.cancelRemoval = NO;
            [editor removeListOfUsers:users error:&replyError];
            reply(replyError);
        }];
    } else {
        reply(error);
    }
}

- (void)cancelUserRemoval
{
    [[ODManagerEditor sharedEditor] setCancelRemoval:YES];
}

#pragma mark Add Users to Groups
- (BOOL)addUser:(NSString*)user toGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    return [self addUsers:@[ user ] toGroup:group error:error];
}

- (BOOL)addUsers:(NSArray*)users toGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    if (_authenticated || [self authenticate:error] > 0) {
        ODManagerEditor* editor = [[ODManagerEditor alloc] initWithNode:_nodeManager.node];
        editor.delegate = _delegate;
        return [editor addUsers:users toGroup:group error:error];
    }
    return NO;
}

- (BOOL)removeUser:(NSString*)user fromGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    return [self removeUsers:@[ user ] fromGroup:group error:error];
}

- (BOOL)removeUsers:(NSArray*)users fromGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    if (_authenticated || [self authenticate:error] > 0) {
        ODManagerEditor* editor = [[ODManagerEditor alloc] initWithNode:_nodeManager.node];
        return [editor removeUsers:users fromGroup:group error:error];
    }
    return NO;
}

- (BOOL)removeAllUsersFromGroup:(NSString*)group error:(NSError* __autoreleasing*)error
{
    if (_authenticated || [self authenticate:error] > 0) {
        ODManagerEditor* editor = [[ODManagerEditor alloc] initWithNode:_nodeManager.node];
        ODRecord* record = [ODManagerRecord getGroupRecord:group node:_nodeManager.node error:error];
        NSDictionary* attributes = [record recordDetailsForAttributes:@[ kODAttributeTypeGroupMembers ] error:nil];
        NSArray* users = attributes[@"dsAttrTypeStandard:GroupMembers"];
        if (users.count)
            return [editor removeUsers:users fromGroup:group error:error];
        else
            return YES;
    }
    return NO;
}

#pragma mark Add Groups
- (BOOL)addGroup:(ODGroup*)group error:(NSError*)error
{
    return NO;
}

- (BOOL)addGroups:(ODRecordList*)list error:(NSError*)error
{
    return NO;
}
- (BOOL)removeGroup:(NSString*)group error:(NSError*)error
{
    return NO;
}

- (BOOL)removeGroups:(NSArray*)groups error:(NSError*)error
{
    return NO;
}

#pragma mark - Passwords

- (BOOL)resetPassword:(NSString*)oldPassword toPassword:(NSString*)newPassword user:(NSString*)user
{
    return [self resetPassword:oldPassword toPassword:newPassword user:user error:nil];
}

- (BOOL)resetPassword:(NSString*)oldPassword toPassword:(NSString*)newPassword user:(NSString*)user error:(NSError* __autoreleasing*)error
{
    ODManagerEditor* editor = [[ODManagerEditor alloc] initWithNode:_nodeManager.node
                                                             status:_authenticated];

    return [editor changePassword:oldPassword to:newPassword user:user error:error];
}

#pragma mark - Node
- (BOOL)refreshNode
{
    return [self refreshNode:nil];
}

- (BOOL)refreshNode:(NSError* __autoreleasing*)error
{
    BOOL rc = [self getServerNode:error];
    if (rc && _diradmin && _diradminPassword) {
        [self authenticate:error];
    };
    return rc;
}

- (BOOL)getServerNode:(NSError* __autoreleasing*)error
{
    if (_nodeManager.status > 0) {
        return YES;
    }

    _nodeManager = [[ODManagerNode alloc] initWithServer:_directoryServer domain:_directoryDomain];

    if (_delegate)
        _nodeManager.delegate = _delegate;
    else
        _nodeManager.delegate = self;

    [_nodeManager getServerNode:_diradmin pass:_diradminPassword error:error];

    if (_nodeManager.node) {
        return YES;
    }
    return NO;
}

- (ODManagerNodeStatus)authenticate
{
    return [self authenticate:nil];
}

- (ODManagerNodeStatus)authenticate:(NSError* __autoreleasing*)error
{
    if (!_nodeManager.node && ![self getServerNode:error]) {
        return kODMNodeNotSet;
    }

    if (_nodeManager.domain == kODMProxyDirectoryServer) {
        _authenticated = _nodeManager.status > 0 ? YES : NO;
        return _nodeManager.status;
    }

    if (_delegate)
        _nodeManager.delegate = _delegate;
    else
        _nodeManager.delegate = self;

    OSStatus status = [_nodeManager authenticateWithUser:_diradmin password:_diradminPassword error:error];

    _authenticated = status > 0 ? YES : NO;

    return status;
}

- (BOOL)authCheck:(NSError* __autoreleasing*)error
{
    if (!_authenticated || ![self authenticate:error]) {
        return NO;
    }
    return YES;
}

#pragma mark - Observers;
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"directoryServer"] || [keyPath isEqualToString:@"directoryDomain"]) {
        [self getServerNode:nil];
    }
}

#pragma mark - Setters/Getters
- (void)setDiradmin:(NSString*)diradmin
{
    _diradmin = diradmin;
}

- (void)setDiradminPassword:(NSString*)diradminPassword
{
    _diradminPassword = diradminPassword;
}

- (void)setDirectoryServer:(NSString*)directoryServer
{
    _directoryServer = directoryServer;
    [self getServerNode:nil];
}

- (void)setDirectoryDomain:(ODMDirectoryDomains)directoryDomain
{
    _directoryDomain = directoryDomain;
    [self getServerNode:nil];
}

- (NSString*)description
{
    NSString* dd = domainDescription(_directoryDomain);
    return [NSString stringWithFormat:@"ODManager - Server:%@ Domain:%@", _directoryServer, dd];
}

/////////////////////////////////////////////////////////////////////////////////////////
///  This becomes The delegate to handle Blocks
/////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - ODManagerDelegate
- (void)didRecieveStatusUpdate:(OSStatus)status
{
    self.status = status;
    if (_nodeStatusUpdateHandler) {
        _nodeStatusUpdateHandler(status);
    }
}

@end

NSString* domainDescription(int domain)
{
    NSString* dd;
    switch (domain) {
    case kODMProxyDirectoryServer: {
        dd = @"Proxy Server";
        break;
    }
    case kODMDefaultDomain: {
        dd = @"Default Domain";
        break;
    }
    case kODMDirectoryServiceDomain: {
        dd = @"Directory Service Domain";
        break;
    }
    case kODMLocalDomain: {
        dd = @"Local Domain";
        break;
    }
    default: {
        dd = @"unknown";
    }
    }
    return dd;
}

NSString* nodeStatusDescription(int status)
{
    NSString* sd;
    switch (status) {
    case kODMNodeAuthenticatedLocal: {
        sd = @"Authenticated Locally";
        break;
    }
    case kODMNodeAuthenticatedProxy: {
        sd = @"Authenticate over Proxy";
        break;
    }
    case kODMNodeNotAuthenticatedLocal: {
        sd = @"Unauthenticated Local Connection";
        break;
    }
    case kODMNodeNotAutenticatedProxy: {
        sd = @"Unauthenticated Proxy Connection";
        break;
    }
    default: {
        sd = @"Unauthenticated";
    }
    }
    return sd;
}
