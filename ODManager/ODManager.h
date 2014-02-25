//  ODManager.h
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
#import "ODSecureObjects.h"
extern NSString* domainDescription(int domain);
extern NSString* nodeStatusDescription(int status);

typedef NS_ENUM(NSInteger, ODMDirectoryDomains){
    kODMLocalDomain            = 0x2200,
    kODMDefaultDomain          = 0x2201,
    kODMDirectoryServiceDomain = 0x2202,
    kODMProxyDirectoryServer   = 0x2203,
};

typedef NS_ENUM(NSInteger,ODManagerNodeStatus){
    kODMNodeAuthenticatedProxy    =  2,
    kODMNodeAuthenticatedLocal    =  1,
    kODMNodeNotSet                =  0,
    kODMNodeNotAuthenticatedLocal = -1,
    kODMNodeNotAutenticatedProxy  = -2,
};

extern NSString* kODMUserRecord;
extern NSString* kODMGroupRecord;
extern NSString* kODMPresetRecord;

@class ODManager;
/**
 *  Open Directory Manager Delegate
 */
@protocol ODManagerDelegate <NSObject>
@optional
/**
 *  sent when new query recieves a record
 *
 *  @param record Dictionary with two keys Type and Name
 */
-(void)didRecieveQueryUpdate:(NSDictionary*)record;

/**
 *  sent when node status is changed
 *
 *  @param status cooresponsd to ODManagerNodeStatus enum values
 */
-(void)didRecieveStatusUpdate:(OSStatus)status;

/**
 *  sent when a record is added to the directory
 *
 *  @param record   name of record added to directory
 *  @param progress value to populate progress indicator x/100
 */
-(void)didAddRecord:(NSString*)record progress:(double)progress;

/**
 *  sent when user is added to group
 *
 *  @param user     name of user
 *  @param group    name of group
 *  @param progress value to populate progress indicator x/100
 */
-(void)didAddUser:(NSString *)user toGroup:(NSString*)group progress:(double)progress;

/**
 *  sent when a record is removed from the directory
 *
 *  @param record   name of record added to directory
 *  @param progress value to populate progress indicator x/100
 */
-(void)didRemoveUser:(NSString *)user fromGroup:(NSString*)group progress:(double)progress;
@end

/**
 *  Open Directory Manager
 *  Objective-c class for interacting with an OpenDirectory Server
 *
 */
@interface ODManager : NSObject
///------------------------------
/// @name Singleton
///------------------------------
/**
 *  ODManger singleton object
 *
 *  @return const ODManger singleton object
 */
+(ODManager*)sharedManager;

///------------------------------
/// @name Properties
///------------------------------
/**
 *  ODManager Delegate
 */
@property (weak) id<ODManagerDelegate>delegate;
/**
 *  Open Directory Server, IP address or DNS entry
 */
@property (copy,nonatomic) NSString *directoryServer;
/**
 *  Directory Admin Name
 */
@property (copy,nonatomic) NSString *diradmin;

/**
 *  Directory Admin Password
 */
@property (copy,nonatomic) NSString *diradminPassword;

/**
 *  Open Directory Domain, Local, Proxy, Default.  Cooresponds ODMDirectoryDomains
 */
@property (readwrite,nonatomic) ODMDirectoryDomains directoryDomain;

/**
 *  block that is called when the node status changes.  The block has no return value and one argument: OSStatus;
 */
@property (copy) void (^nodeStatusUpdateHandler)(OSStatus status);

/**
 *  wether the node is currently authenticated
 */
@property (nonatomic,readonly ) BOOL authenticated;

-(id)initWithDelegate:(id<ODManagerDelegate>)delegate;
-(id)initWithServer:(NSString*)server;
-(id)initWithServer:(NSString *)server domain:(int)domain;
-(id)initWithDomain:(ODMDirectoryDomains)domain;
-(id)initWithDefaultDomain;
#pragma mark - Authenticate

///------------------------------
/// @name Authenticate
///------------------------------

/**
 *  Called to authenticate agains the directory server with current credentials
 *
 *  @return Authentication Status of the node
 */
-(ODManagerNodeStatus)authenticate:(NSError**)error;
-(ODManagerNodeStatus)authenticate;

/**
 *  Refresh the connection status and re-authenticate to the node
 *
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)refreshNode:(NSError**)error;
-(BOOL)refreshNode;

#pragma mark - Add Users
///------------------------------
/// @name Add Users
///------------------------------
/**
 *  Synchronously add a single User
 *
 *  @param user  ODUser Object
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addUser:(ODUser*)user
         error:(NSError**)error;

/**
 *  Asynchronously add a list of users
 *
 *  @param users ODUserList with the user property populated with an array of ODUser objects
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSError. */
-(void)addListOfUsers:(ODRecordList*)list
                reply:(void(^)(NSError *error))reply;

/**
 *  Asynchronously add list of users asyn with status updates provided via a block object
 *
 *  @param users ODUserList with the user property populated with an array of ODUser objects
 *  @param progress block object to be excuted when a user is added.  This block has no return value and takes two arguments, NSString and double
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSError.
 *  @discussion Use this when not implamenting a delegate.
 */
-(void)addListOfUsers:(ODRecordList*)list
             progress:(void(^)(NSString* message,double progress))progress
                reply:(void(^)(NSError *error))reply;
/**
 *  Synchronously add a user using a Preset template
 *
 *  @param user  populated user object
 *  @param preset name of preset
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addUser:(ODUser*)user
    withPreset:(NSString*)preset
         error:(NSError**)error;

/**
 *  Asynchronously add list of users asyn with status updates provided via a block object
 *
 *  @param users ODUserList with the user property populated with an array of ODUser objects
 *  @param preset name of preset
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSError.
 *  @discussion use this when implementing a delegate
 */
-(void)addListOfUsers:(ODRecordList*)list
           withPreset:(NSString*)preset
                reply:(void(^)(NSError *error))reply;

/**
 *  Asynchronously add list of users asyn with status updates provided via a block object
 *
 *  @param users ODUserList with the user property populated with an array of ODUser objects
 *  @param preset name of preset
 *  @param progress block object to be excuted when a user is added.  This block has no return value and takes two arguments, NSString and double
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSError.
 */
-(void)addListOfUsers:(ODRecordList*)list
              withPreset:(NSString*)preset
                progress:(void(^)(NSString* message,double progress))progress
                   reply:(void(^)(NSError *error))reply;

/**
 *  Cancesl any add user list operation in progress.
 */
-(void)cancelUserImport;
#pragma mark - Remove Users
///------------------------------
/// @name Remove Users
///------------------------------
/**
 *  Synchronously remove a user from the OpenDirectory database
 *
 *  @param user  record name for the user.
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeUser:(NSString*)user error:(NSError**)error;

/**
 *  Asynchronously remove a list user from the OpenDirectory database
 *
 *  @param user  record name for the user.
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(void)removeUsers:(NSArray*)users reply:(void(^)(NSError *error))reply;
/**
 *  stops any add remove user list operation in progress.
 */
-(void)cancelUserRemoval;

#pragma mark - Add Groups
///------------------------------
/// @name Add Groups
///------------------------------
/**
 *  Add a group to the OpenDirectory Server
 *
 *  @param group Populated ODGroup Object
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addGroup:(ODGroup*)group error:(NSError*)error;

/**
 *  Add a list of groups to the OpenDirectory Server
 *
 *  @param groups ODGroupList with the groups key set to an array of populated ODGroup objects
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addGroups:(ODRecordList*)list error:(NSError*)error;

/**
 *  Add a group to the OpenDirectory Server
 *
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeGroup:(NSString*)group error:(NSError*)error;

/**
 *  Add a group to the OpenDirectory Server
 *
 *  @param group Array of group record names
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeGroups:(NSArray*)groups error:(NSError*)error;

#pragma mark - Group Modification
///------------------------------
/// @name Edit Groups
///------------------------------

/**
 *  Add a single user to a group
 *
 *  @param user  user record name
 *  @param group group record namd
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addUser:(NSString*)user toGroup:(NSString*)group error:(NSError**)error;

/**
 *  Add list of users to a group
 *
 *  @param users Array of user record names
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)addUsers:(NSArray*)users toGroup:(NSString*)group error:(NSError**)error;

/**
 *  Removes a user from a group
 *
 *  @param user  user record name
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeUser:(NSString*)user fromGroup:(NSString*)group error:(NSError**)error;

/**
 *  Removes list of users from group
 *
 *  @param users Array of user record names
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeUsers:(NSArray*)users fromGroup:(NSString*)group error:(NSError**)error;

/**
 *  Removes all users from a group
 *
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)removeAllUsersFromGroup:(NSString*)group error:(NSError**)error;


#pragma mark - Preset
///------------------------------
/// @name Preset
///------------------------------
/**
 *  Retreive the preset settings from a given presest
 *
 *  @param preset preset record name
 *
 *  @return Populated ODPreset object
 */
-(ODPreset*)settingsForPreset:(NSString*)preset;

/**
 *  Reset Password
 *
 *  @param oldPassword the password you have
 *  @param newPassword the password you want
 *  @param user record name of the user
 *
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)resetPassword:(NSString*)oldPassword toPassword:(NSString *)newPassword user:(NSString*)user error:(NSError **)error;
-(BOOL)resetPassword:(NSString*)oldPassword toPassword:(NSString *)newPassword user:(NSString*)user;

#pragma mark - Query
///------------------------------
/// @name Query
///------------------------------

/**
 *  Get the group membership of a group
 *
 *  @param group group record name
 *
 *  @return Array of user record names
 */
-(NSArray *)groupMembers:(NSString*)group;

/**
 *  Asynchronous query of users in active node
 *
 *  @param delegate delegate object that will recieve the didRecieveQueryUpdate:
 *  @discussion the dictionary sent to the delegate will conatin the string "user" for the "type" key
 */
-(void)userListWithDelegate:(id<ODManagerDelegate>)delegate;

/**
 *  Asynchronous query of users in active node
 *
 *  @param delegate delegate object that will recieve the didRecieveQueryUpdate:
 *  @discussion the query will return a dictionary with two keys type and name
 */
-(void)presetListWithDelegate:(id<ODManagerDelegate>)delegate;

/**
 *  Asynchronous query of users in active node using a delegate
 *
 *  @param delegate delegate object that will recieve the didRecieveQueryUpdate:
 *  @discussion the query will return a dictionary with two keys type and name
 */
-(void)groupListWithDelegate:(id<ODManagerDelegate>)delegate;

/**
 *  Asynchronous query of users in active node using a block reply
 *
 *  @param reply A block object to be executed each time a new user is discovered. This block has no return value and takes one argument: NSDictionary.  The array is an array of all the user record names.
 *  @discussion the block will return a dictionary with two keys type and name for each user

 */
-(void)userListWithBlock:(void(^)(NSDictionary*))reply;

/**
 *  Get a list of all the users in the directory
 *
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSArray.  The array is an array of all the user record names.
 *  @discussion This is non blocking, but sychronous
 */
-(void)userList:(void(^)(NSArray *allUsers))reply;

/**
 *  Get an list of the avaliable preset record names in the current directory
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSArray.  The array is an array of all the preset record names.
 *  @discussion This is non blocking, but sychronous
 */
-(void)presetList:(void(^)(NSArray *allPresets))reply;

/**
 *  Get a list of all the groups in the directory
 *
 *  @param reply A block object to be executed when the request operation finishes. This block has no return value and takes one argument: NSArray.  The array is an array of all the group record names.
 *  @discussion This is non blocking, but sychronous
 */
-(void)groupList:(void(^)(NSArray *allGroups))reply;

/**
 *  List of nodes the current computer is connected to
 *
 *  @return Array of node names
 */
-(NSArray*)avaliableLocalNodes;

/**
 *  Checks if a user is a mmeber of a group
 *
 *  @param user  user record name
 *  @param group group record name
 *  @param error populated should error occur
 *
 *  @return YES for success, NO on failure.
 */
-(BOOL)user:(NSString*)user isMemberOfGroup:(NSString *)group error:(NSError**)error;


@end
