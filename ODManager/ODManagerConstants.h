//
//  ODManagerConstants.h
//  ODManager
//
//  Created by Eldon on 4/15/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#ifndef ODManager_ODManagerConstants_h
#define ODManager_ODManagerConstants_h

typedef NS_ENUM(int, ODMErrorCodes){
    kODMerrSuccess                      = 0,
    kODMerrCouldNotConnectToNode        = 1000,
    kODMerrNoUserRecord,
    kODMerrNoGroupRecord,
    kODMerrNoPresetRecord,
    kODMerrNoMatchingRecord,
    
    kODMerrWrongPassword                = 2002,
    kODMerrNoPasswordSupplied,
    kODMerrInvakidCredentials,
    kODMerrODSessionError,
    kODMerrNoDirectoryNode              = 2006,
    
    kODMerrCouldNotAddUser              = 3000,
    kODMerrUserAlreadyExists,
    kODMerrCouldNotRemoveUser,
    kODMerrCouldNotAddGroup,
    kODMerrCouldNotRemoveGroup,
    kODMerrCouldNotAddUserToGroup,
    kODMerrCouldNotRemoveUserFromGroup,
    kODMerrIncompleteUserObject,
    kODMerrIncompleteGroupObject,
};

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


#endif
