//
//  ODManagerNode.h
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

@interface ODManagerNode : NSObject
@property (weak) id<ODManagerDelegate>delegate;
@property (copy) NSString *server;
@property int domain;

-(id)initWithDomain:(int)domain ;
-(id)initWithServer:(NSString*)server domain:(int)domain;

-(ODNode*)getServerNode:(NSString*)user pass:(NSString*)password error:(NSError**)error;
-(OSStatus)authenticateToNode:(ODNode*)node user:(NSString*)user password:(NSString*)password error:(NSError**)error;

@end
