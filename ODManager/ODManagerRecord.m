//
//  ODManagerRecord.m
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

#import "ODManagerRecord.h"
#import "ODManagerError.h"
#import "TBXML.h"

@implementation ODManagerRecord{
    ODQuery *_query;
    NSDictionary *_queryReturn;
    NSMutableArray *_replyResults;
    BOOL queryFault;
}
-(id)initWithNode:(ODNode *)node{
    self = [super init];
    if(self){
        self.node = node;
    }
    return self;
}

-(id)initWithNode:(ODNode *)node delegate:(id<ODManagerDelegate>)delegate{
    self = [self initWithNode:node];
    if(self){
        _delegate = delegate;
    }
    return self;
}

/*ODUser Query*/
-(void)asyncQueryWithType:(NSString*)type;
{
    _query = [ODQuery queryWithNode: _node
                     forRecordTypes: type
                          attribute: kODAttributeTypeRecordName
                          matchType: kODMatchAny
                        queryValues: nil
                   returnAttributes: kODAttributeTypeStandardOnly
                     maximumResults: 0
                              error: nil];
    
    [_query setDelegate:self];
    [_query scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(NSArray *)listQueryWithType:(NSString *)type{
    return [self allRecordsOfType:type error:nil];
}


-(NSArray*)allRecordsOfType:(NSString*)type error:(NSError*__autoreleasing*)error{
    ODQuery *query = [ODQuery queryWithNode: _node
                             forRecordTypes: type
                                  attribute: kODAttributeTypeRecordName
                                  matchType: kODMatchAny
                                queryValues: nil
                           returnAttributes: kODAttributeTypeStandardOnly
                             maximumResults: 0
                                      error: nil];
    
    NSArray *odArray = [query resultsAllowingPartial:NO error:nil];
    NSMutableArray *array;
    
    for (ODRecord *record in odArray) {
        if(!array)array = [NSMutableArray arrayWithCapacity:[odArray count]];
        {
            [array addObject:[record recordName]];
        }
    }
    return array;
}

-(void)query:(ODQuery *)inQuery foundResults:(NSArray *)inResults error:(NSError *)inError{
    if(inError){
        NSLog(@"Error during query: %@", inError.localizedDescription );
        queryFault = YES;
    }
    
    if (!inResults && !inError){
        [inQuery removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    for (ODRecord *record in inResults) {
        id returnRecord;

        if([[record recordType] isEqualToString:kODRecordTypeUsers]){
            returnRecord = [ODUser new];
            [(ODUser*) returnRecord setUserName:record.recordName];
            [(ODUser*) returnRecord setFirstName:record.firstName];
            [(ODUser*) returnRecord setLastName:record.lastName];
            [(ODUser*) returnRecord setUid:record.uid];
            [(ODUser*) returnRecord setUserShell:record.userShell];
        }else if ([[record recordType] isEqualToString:kODRecordTypePresetUsers]){
            returnRecord = [ODPreset new];
            [(ODPreset*) returnRecord setPresetName:record.recordName];
        }else if ([[record recordType] isEqualToString:kODRecordTypeGroups]){
            returnRecord = [ODGroup new];
            [(ODGroup*) returnRecord setGroupName:record.recordName];
        }
        
        if(_delegate)
            [_delegate didRecieveQueryUpdate:returnRecord];
        if(_queryReplyBlock)
            _queryReplyBlock(returnRecord);
    }
}



#pragma mark - Class Methods
+(ODRecord *)getUserRecord:(NSString *)user node:(ODNode *)node error:(NSError *__autoreleasing *)error
{
    return [self search:node match:user type:kODRecordTypeUsers error:error];
}

+(ODRecord *)getGroupRecord:(NSString *)group node:(ODNode *)node error:(NSError *__autoreleasing *)error
{
    return [self search:node match:group type:kODRecordTypeGroups error:error];
}

+(ODRecord *)getPresetRecord:(NSString *)preset node:(ODNode *)node error:(NSError *__autoreleasing *)error{
    return [self search:node match:preset type:kODRecordTypePresetUsers error:error];
}

+(ODRecord *)getRecordByGUID:(NSString *)guid type:(NSString*)type node:(ODNode *)node error:(NSError *__autoreleasing *)error{
    return [self search:node match:guid type:type attr:kODAttributeTypeGUID error:error];
}

+(ODRecord*)search:(ODNode*)node match:(NSString*)match type:(NSString*)type error:(NSError *__autoreleasing*)error{
    return [self search:node match:match type:type attr:nil error:error];
}


+(ODRecord*)search:(ODNode*)node match:(NSString*)match type:(NSString*)type attr:(NSString*)attr error:(NSError *__autoreleasing*)error
{
    if(!match || !node){
        [ODManagerError errorWithMessage:@"Something is missing" error:error];
        return nil;
    }
    
    if(!attr){
        attr = kODAttributeTypeRecordName;
    }
    
    NSError *err;
    ODQuery  *query = [ODQuery queryWithNode: node
                              forRecordTypes: type
                                   attribute: attr
                                   matchType: kODMatchEqualTo
                                 queryValues: match
                            returnAttributes: kODAttributeTypeStandardOnly
                              maximumResults: 1
                                       error: &err];
    
    if(err){
        if(error)*error = err;
        return nil;
    }
    
    NSArray *results = [query resultsAllowingPartial:NO error:error];
    if(results.count){
        return results[0];
    }
    
    [ODManagerError errorWithCode:kODMerrNoMatchingRecord error:error];
    return nil;
}


+(NSArray*)groupMembers:(NSString*)group node:(ODNode*)node{
    ODRecord  *record = [self getGroupRecord:group node:node error:nil];
    NSDictionary *attributes= [record recordDetailsForAttributes:@[kODAttributeTypeGroupMembership] error:nil];
    return attributes[@"dsAttrTypeStandard:GroupMembership"];
}


+(BOOL)user:(NSString*)user isMemberOfGroup:(NSString*)group node:(ODNode*)node error:(NSError *__autoreleasing *)error{
    ODRecord* userRecord = [self getUserRecord:user node:node error:error];
    if(!userRecord)return NO;
    
    ODRecord* groupRecord = [self getGroupRecord:group node:node error:error];
    if(!userRecord)return NO;
    
    return [groupRecord isMemberRecord:userRecord error:error];
}

+(ODPreset *)settingsForPrest:(NSString*)preset node:(ODNode*)node{
    ODPreset* pst;
    ODRecord* record = [self getPresetRecord:preset node:node error:nil];
    
    if (record) {
        pst = [ODPreset new];
        pst.presetName = record.recordName;
        pst.primaryGroup = record.primaryGroup;
        pst.userShell = record.userShell;
        pst.nfsPath = record.NFSHomeDirectory;
        pst.sharePath = record.sharePath;
        pst.sharePoint = record.sharePoint;
    }
    return pst;
}

@end

#pragma mark - ODRecord Extensions
@implementation ODRecord (Convience)
-(NSString *)fullName{
    return [[self valuesForAttribute:kODAttributeTypeFullName error:nil]lastObject];
};
-(NSString *)firstName{
    return [[self valuesForAttribute:kODAttributeTypeFirstName error:nil]lastObject];
};
-(NSString *)lastName{
    return [[self valuesForAttribute:kODAttributeTypeLastName error:nil]lastObject];
};
-(NSString *)uid{
    return [[self valuesForAttribute:kODAttributeTypeUniqueID error:nil]lastObject];
}
-(NSString *)primaryGroup{
    return [[self valuesForAttribute:kODAttributeTypePrimaryGroupID error:nil]lastObject];
}
-(NSString *)userShell{
    return [[self valuesForAttribute:kODAttributeTypeUserShell error:nil]lastObject];
};
-(NSString *)homeDirectory{
    return [[self valuesForAttribute:kODAttributeTypeHomeDirectory error:nil]lastObject];
}
-(NSString *)NFSHomeDirectory{
    return [[self valuesForAttribute:kODAttributeTypeNFSHomeDirectory error:nil]lastObject];
}
-(NSString *)sharePath{
    NSString *val = [TBXML getValueForKey:@"path" fromXMLString:self.homeDirectory];
    if([val isEqualToString:@"(null)"]){
        return nil;
    }
    return  val;
};
-(NSString *)sharePoint{
    NSString* val = [TBXML getValueForKey:@"url" fromXMLString:self.homeDirectory];
    if([val isEqualToString:@"(null)"]){
        return nil;
    }
    return val;
};

@end
