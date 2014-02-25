//
//  ODSecureObjects.h
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



#pragma mark - User
/**
 *  User object for use with ODManager.
 *  @discussion  uses NSSecure Coding to facilitate use across an NSXPC connection
 */
@interface ODUser : NSObject <NSSecureCoding>
@property (copy) NSString *userName;
@property (copy) NSString *firstName;
@property (copy) NSString *lastName;
@property (copy) NSString *passWord;
@property (copy) NSString *uid;

@property (copy) NSString *primaryGroup;
@property (copy) NSString *emailDomain;
@property (copy) NSString *keyWord;
@property (copy) NSString *userPreset;

@property (copy) NSString *sharePoint;
@property (copy) NSString *sharePath;
@property (copy) NSString *nfsPath;
@property (copy,nonatomic) NSString *homeDirectory;
@property (copy) NSString *userShell;

@end

#pragma mark - RecordList
/**
 *  Record list object for use with ODManager.
 *  @discussion  uses NSSecure Coding to facilitate use across an NSXPC connection
 */
@interface ODRecordList : NSObject <NSSecureCoding>
@property (copy) NSArray *users;
@property (copy) NSArray *groups;
@property (copy) NSArray *filter;
@end

#pragma mark - Group
/**
 *  Group object for use with ODManager.
 *  @discussion  uses NSSecure Coding to facilitate use across an NSXPC connection
 */
@interface ODGroup : NSObject <NSSecureCoding>
@property (copy) NSString *groupName;
@property (copy) NSString *fullName;
@property (copy) NSString *guid;
@property (copy) NSString *owner;
@end



#pragma mark - Preset
/**
 *  Preset object for use with ODManager.
 *  @discussion  uses NSSecure Coding to facilitate use across an NSXPC connection
 */
@interface ODPreset : NSObject <NSSecureCoding>
@property (copy) NSString *presetName;
@property (copy) NSString *userShell;
@property (copy) NSString *nfsPath;
@property (copy) NSString *sharePath;
@property (copy) NSString *sharePoint;
@property (copy) NSString *primaryGroup;
@property (copy) NSString *mcxFlags;
@property (copy) NSString *mcxSettings;
@end

#pragma mark - Server
/**
 *  User object for use with ODManager.
 *  @discussion  uses NSSecure Coding to facilitate use across an NSXPC connection
 */
@interface ODServer : NSObject <NSSecureCoding>
@property (copy) NSString *directoryServer;
@property (copy) NSString *directoryDomain;
@property (copy) NSString *diradminName;
@property (copy) NSString *diradminPass;
@end

#pragma Custom Related Catagories
@interface NSString (uuidWithLength)
-(NSString*)uuidWithLength:(int)lenght;
@end