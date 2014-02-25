//
//  ODMangaerTests.m
//  ODMangaerTests
//
//  Created by Eldon on 2/17/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ODManager.h"
#import <OpenDirectory/OpenDirectory.h>

@interface ODMangaerTests : XCTestCase

@end

@implementation ODMangaerTests{
    ODManager *_manager;
    ODUser *user;
}

- (void)setUp
{
    [super setUp];
    [self setupManager];
    [self setupUser];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testAuthToServer{
    XCTAssertTrue(_manager.authenticated, @"Manager Is Not authenticated");
}

-(void)testAddUser{
    NSError* error;
    [_manager addUser:user error:&error];
    XCTAssertNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(void)testAddUserShouldFail{
    NSError* error;
    [_manager addUser:user error:&error];
    XCTAssertNotNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(void)testResetPasswordAsAdmin{
    NSError* error;
    [_manager resetPassword:nil toPassword:@"test" user:user.userName];
    XCTAssertNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(void)testAddUserToGroup{
    NSError* error;
    [_manager addUser:user.userName toGroup:@"Workgroup" error:&error];
    XCTAssertNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(void)testRemoveUserFromGroup{
    NSError* error;
    [_manager removeUser:user.userName fromGroup:@"Workgroup" error:&error];
    XCTAssertNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(void)testRemoveUser{
    NSError* error;
    [_manager removeUser:user.userName error:&error];
    XCTAssertNil(error,@"%s",__PRETTY_FUNCTION__);
}

-(ODManager*)setupManager{
    if(!_manager){
        _manager = [ODManager new];
        _manager.nodeStatusUpdateHandler = ^(OSStatus status){
            NSLog(@"Status Change:[%d] %@",status, nodeStatusDescription(status));
        };
        _manager.diradmin = @"diradmin";
        _manager.diradminPassword=@"testpassword";
        
        _manager.directoryServer=@"127.0.0.1";
        [_manager authenticate];
    }
    return _manager;
}

-(void)testNodeActive{
}

-(ODUser*)setupUser{
    if(!user){
        user = [ODUser new];
        user.userName = @"holcom";
        user.firstName = @"harrold";
        user.lastName = @"olkem";
        user.emailDomain = @"mysite.com";
        user.primaryGroup = @"20";
        user.passWord = @"dummypassword";
    }
    return user;
}

@end
