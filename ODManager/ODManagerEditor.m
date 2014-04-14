//
//  ODManagerEditor.m
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
#import "ODManagerEditor.h"
#import <OpenDirectory/OpenDirectory.h>
#import "ODManagerRecord.h"
#import "ODManagerError.h"
#import "TBXML.h"

@interface ODUser (odAttributes)
@property (copy,nonatomic,readonly) NSDictionary* openDirectoryAttributes;
@end

@implementation ODManagerEditor{
    double progress;
}

#pragma mark - Singleton
+(ODManagerEditor *)sharedEditor{
    static dispatch_once_t onceToken;
    static ODManagerEditor *shared;
    dispatch_once(&onceToken, ^{
        shared = [ODManagerEditor new];
    });
    return shared;
}

#pragma mark - Iniitializers
-(id)initWithNode:(ODNode *)node{
    self = [super init];
    if(self){
        _node = node;
    }
    return self;
}

-(id)initWithNode:(ODNode *)node status:(BOOL)status{
    self = [self initWithNode:node];
    if(self){
        _authenticated = status;
    }
    return self;
}

#pragma mark - ODUser
-(BOOL)addUsers:(ODRecordList*)list error:(NSError*__autoreleasing*)error{
    _continueImport = YES;
    NSInteger faults = 0;
    NSError *err;
    NSMutableArray* failures = [[NSMutableArray alloc]initWithCapacity:list.users.count];
    NSMutableArray* success = [[NSMutableArray alloc]initWithCapacity:list.users.count];
    BOOL rc = YES;
    
    if(!_node){
        [ODManagerError errorWithCode:kODMerrNoDirectoryNode error:&err];
        if(_errorReplyBlock)_errorReplyBlock(err);
        return NO;
    }
    
    progress = 0.0;
    for(ODUser* user in list.users){
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            progress++;
            if(_progressUpdateBlock){
                _progressUpdateBlock(user.userName,(progress/list.users.count*100));
            }
            if(_delegate)
                [_delegate didAddRecord:user.userName progress:(progress/list.users.count*100)];
        }];
        
        if(!_continueImport){
            [ODManagerError errorWithMessage:@"Import Canceled" error:error];
            if(_errorReplyBlock && error)_errorReplyBlock(*error);
            return NO;
        }
        
        if(!user.userName || !user.passWord || !user.firstName || !user.lastName){
            [ODManagerError errorWithCode:kODMerrIncompleteUserObject error:error];
        }
        
        ODRecord *userRecord = [_node createRecordWithRecordType:kODRecordTypeUsers
                                                            name:user.userName
                                                      attributes:user.openDirectoryAttributes
                                                           error:&err];
        if(err){
            if(error)*error = err;
            [failures addObject:user.userName];
            faults++;
            rc = NO;
        }else{
            if(user.passWord){
                rc = [userRecord changePassword:nil toPassword:user.passWord error:&err];
                if(rc)
                    [success addObject:user.userName];
            }
            else
               [ODManagerError errorWithCode:kODMerrNoPasswordSupplied error:&err];
        };
    }
    
    if(faults > 0 && list.users.count > 1){
        [ODManagerError errorWithMessage:@"error adding users.  See log for more info" error:&err];
    }

    if(_errorReplyBlock)_errorReplyBlock(err);
    if(error)*error = err;

    if(list.users.count == 1){
        return rc;
    }else{
        [[self class] logResults:@[@"user",@""] success:success failure:failures];
    }
    
    return YES;
}
/***/

-(BOOL)addUsers:(ODRecordList *)list withPreset:(NSString *)preset error:(NSError *__autoreleasing *)error{
    if(preset){
        ODRecord* record = [ODManagerRecord getPresetRecord:preset node:_node error:error];
        if(!record){
            return [ODManagerError errorWithCode:kODMerrNoPresetRecord error:error];
        }
        
        for (ODUser* user in list.users) {
            user.userShell = [record userShell] ;
            user.nfsPath   = [record NFSHomeDirectory];
            user.primaryGroup = [record primaryGroup];
            user.sharePath = [record sharePath];
            user.sharePoint = [record sharePoint];
        }
    }
    return [self addUsers:list error:error];
}

/* ***/

-(BOOL)removeUser:(NSString *)user error:(NSError *__autoreleasing *)error{
    return [self removeListOfUsers:@[user] error:error];
}

-(BOOL)removeListOfUsers:(NSArray *)users error:(NSError *__autoreleasing *)error{
    BOOL rc = NO;
    _cancelRemoval = NO;
    for (NSString* user in users){
        if(_cancelRemoval){
            return [ODManagerError errorWithMessage:@"ODUser Removal Canceled" error:error];
        }
        ODRecord* userRecord = [ODManagerRecord getUserRecord:user node:_node error:error];
        rc = [userRecord deleteRecordAndReturnError:error];
    }
    
    return users.count > 1 ? YES:rc;
}
/* ***/

#pragma mark - ODGroup
-(BOOL)addGroup:(ODGroup *)group error:(NSError *__autoreleasing *)error{
    return NO;
}
/* ***/

-(BOOL)removeGroup:(ODRecord *)group error:(NSError *__autoreleasing *)error{
    return NO;
}

#pragma mark - ODUser/ODGroup
-(BOOL)addUsers:(NSArray*)users toGroup:(NSString *)group error:(NSError *__autoreleasing *)error{
    NSError* err;
    ODRecord* groupRecord = [ODManagerRecord getGroupRecord:group node:_node error:error];
    NSMutableArray* failures = [[NSMutableArray alloc]initWithCapacity:users.count];
    NSMutableArray* success = [[NSMutableArray alloc]initWithCapacity:users.count];
    NSInteger* faults = 0;
    BOOL rc = YES;
    double count = 0.0;
    _continueImport = YES;
    while(_continueImport){
        for(NSString* user in users){
            if(!_continueImport)break;
            ODRecord* userRecord = [ODManagerRecord getUserRecord:user node:_node error:error];
            if(![groupRecord addMemberRecord:userRecord error:&err]){
                [ODManagerError logError:err];
                [failures addObject:user];
                faults++;
                rc = NO;
            }else{
                count++;
                [_delegate didAddUser:user toGroup:group progress:(count/users.count*100)];
                [success addObject:user];
            }
        }
        break;
    }
    
    if(faults > 0)
        [ODManagerError errorWithMessage:@"error adding users.  See log for more info" error:error];
    if(users.count == 1)
        return rc;
    else
        [[self class] logResults:@[@"group",group] success:success failure:failures];
        return YES;
}

-(BOOL)removeUsers:(NSArray *)users fromGroup:(NSString *)group error:(NSError *__autoreleasing *)error{
    NSError* err;
    ODRecord* groupRecord = [ODManagerRecord getGroupRecord:group node:_node error:error];
    NSMutableArray* failures = [[NSMutableArray alloc]initWithCapacity:users.count];
    NSMutableArray* success = [[NSMutableArray alloc]initWithCapacity:users.count];
    NSInteger* faults = 0;
    BOOL rc = YES;
    double count = 0.0;
    _continueImport = YES;
    while(_continueImport){
        for(NSString* user in users){
            if(!_continueImport)break;
            ODRecord* userRecord = [ODManagerRecord getUserRecord:user node:_node error:&err];
            if(![groupRecord removeMemberRecord:userRecord error:&err]){
                [ODManagerError logError:err];
                [failures addObject:user];
                faults++;
                rc = NO;
            }else{
                count++;
                [_delegate didRemoveUser:user fromGroup:group progress:(count/users.count*100)];
                [success addObject:user];
            }
        }
        break;
    }
    
    if(faults > 0)
        [ODManagerError errorWithMessage:@"error removing users.  See log for more info" error:error];
    if(users.count == 1)
        return rc;
    else
        [[self class] logResults:@[@"group",group] success:success failure:failures];
    return YES;
}


-(BOOL)changePassword:(NSString *)password to:(NSString *)newPassword user:(NSString *)user error:(NSError *__autoreleasing *)error{
    ODRecord* userRecord = [ODManagerRecord getUserRecord:user node:_node error:error];

    if(userRecord){
        if(self.authenticated)password = nil;
        
        if([userRecord changePassword:password toPassword:newPassword error:error])
            return [userRecord synchronizeAndReturnError:nil];
    }
    return NO;
}

#pragma mark - Class Methods
+(void)logResults:(NSArray*)type success:(NSArray*)success failure:(NSArray*)failures{
    if([type[0] isEqualToString:@"group"]){
        NSLog(@"Added users to %@: %@",type[1],success);
        NSLog(@"There were problems adding these users to %@: %@",type[1],failures);

    }else if([type[0] isEqualToString:@"user"]){
        NSLog(@"Added users: %@",success);
        NSLog(@"There were problems adding these users %@",failures);
    }
}
@end


@implementation ODUser (odAttributes)

-(NSDictionary *)openDirectoryAttributes{
    NSMutableDictionary *settings;
    settings = [[NSMutableDictionary alloc]init];
    if(self.sharePoint){
        [settings setObject:@[self.homeDirectory] forKey:@"dsAttrTypeStandard:HomeDirectory"];
    }
    if(self.nfsPath){
        NSString *nfsHome = [self.nfsPath stringByAppendingPathComponent:self.userName];
        [settings setObject:@[nfsHome] forKey:@"dsAttrTypeStandard:NFSHomeDirectory"];
    }
    
    if(self.emailDomain){
        NSString *emailAddress = [NSString stringWithFormat:@"%@@%@",self.userName,self.emailDomain];
        [settings setObject:@[emailAddress] forKey:@"dsAttrTypeStandard:EMailAddress"];
    }
    if(!self.uid){
        self.uid = [self.userName uuidWithLength:6];
    }
    if(!self.userShell){
        self.userShell = @"/bin/null";
    }
    if(!self.primaryGroup){
        self.primaryGroup = @"20";
    }
    [settings setObject:@[[NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName]] forKey:@"dsAttrTypeStandard:RealName"];
    [settings setObject:@[self.firstName] forKey:@"dsAttrTypeStandard:FirstName"];
    [settings setObject:@[self.lastName] forKey:@"dsAttrTypeStandard:LastName"];
    [settings setObject:@[self.uid] forKey:@"dsAttrTypeStandard:UniqueID"];
    [settings setObject:@[self.primaryGroup] forKey:@"dsAttrTypeStandard:PrimaryGroupID"];
    [settings setObject:@[self.userShell] forKey:@"dsAttrTypeStandard:UserShell"];
    return [NSDictionary dictionaryWithDictionary:settings];
}

@end