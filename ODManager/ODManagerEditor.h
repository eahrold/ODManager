//
//  ODManagerEditor.h
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


#import <Foundation/Foundation.h>
#import "ODManager.h"
@class ODNode;

@interface ODManagerEditor : NSObject

@property (weak) ODNode *node;
@property (weak) id<ODManagerDelegate>delegate;
@property (weak,nonatomic) void(^errorReplyBlock)(NSError *error);
@property (weak,nonatomic) void(^progressUpdateBlock)(NSString *message,double progress);

@property BOOL authenticated;
@property BOOL continueImport;
@property BOOL cancelRemoval;

+(ODManagerEditor*)sharedEditor;

-(id)initWithNode:(ODNode*)node;
-(id)initWithNode:(ODNode*)node status:(BOOL)status;

-(BOOL)addUsers:(ODRecordList *)list error:(NSError**)error;
-(BOOL)addUsers:(ODRecordList *)list withPreset:(NSString*)preset error:(NSError**)error;

-(BOOL)removeListOfUsers:(NSArray*)users error:(NSError**)error;

-(BOOL)addGroup:(ODGroup*)group error:(NSError**)error;
-(BOOL)removeGroup:(NSString*)group error:(NSError**)error;

-(BOOL)addUsers:(NSArray*)users toGroup:(NSString *)group error:(NSError **)error;
-(BOOL)removeUsers:(NSArray*)users fromGroup:(NSString *)group error:(NSError **)error;

-(BOOL)changePassword:(NSString*)password to:(NSString*)newPassword user:(NSString* )user error:(NSError**)error;

@end
