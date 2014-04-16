//
//  ODManagerRecord.h
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

#import "ODManager.h"
#import <OpenDirectory/OpenDirectory.h>


@interface ODManagerRecord : ODRecord <ODQueryDelegate>
@property (weak) id<ODManagerDelegate>delegate;
@property (copy) void (^queryReplyBlock)(id record);

@property (weak,nonatomic)   ODNode *node;
@property (strong) void(^replyError)(NSError *error);

-(id)initWithNode:(ODNode *)node;
-(id)initWithNode:(ODNode *)node delegate:(id<ODManagerDelegate>)delegate;

-(void)asyncQueryWithType:(NSString*)type;
-(NSArray *)listQueryWithType:(NSString *)type;

+(ODRecord *)getUserRecord:(NSString *)user node:(ODNode*)node error:(NSError **)error;
+(ODRecord *)getGroupRecord:(NSString *)group node:(ODNode*)node error:(NSError **)error;
+(ODRecord *)getPresetRecord:(NSString *)preset node:(ODNode*)node error:(NSError **)error;
+(ODRecord *)getRecordByGUID:(NSString *)guid type:(NSString*)type node:(ODNode *)node error:(NSError *__autoreleasing *)error;

+(NSArray*)groupMembers:(NSString*)group node:(ODNode*)node;
+(ODPreset *)settingsForPrest:(NSString*)preset node:(ODNode*)node;
+(BOOL)user:(NSString*)user isMemberOfGroup:(NSString*)group node:(ODNode*)node error:(NSError **)error;

@end


@interface ODRecord (Convience)
@property (readonly,nonatomic) NSString *fullName;
@property (readonly,nonatomic) NSString *firstName;
@property (readonly,nonatomic) NSString *lastName;
@property (readonly,nonatomic) NSString *sharePoint;
@property (readonly,nonatomic) NSString *uid;
@property (readonly,nonatomic) NSString *primaryGroup;
@property (readonly,nonatomic) NSString *sharePath;
@property (readonly,nonatomic) NSString *userShell;
@property (readonly,nonatomic) NSString *NFSHomeDirectory;
@property (readonly,nonatomic) NSString *homeDirectory;
@end