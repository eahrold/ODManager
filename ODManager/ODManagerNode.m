//
//  ODManagerNode.m
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

#import "ODManagerNode.h"
#import "ODManagerError.h"
#import <OpenDirectory/OpenDirectory.h>

@implementation ODManagerNode

- (id)initWithDomain:(int)domain
{
    self = [super init];
    if (self) {
        _domain = domain;
    }
    return self;
}

- (id)initWithServer:(NSString*)server domain:(int)domain
{
    self = [super init];
    if (self) {
        _server = server;
        _domain = domain;
    }
    return self;
}

- (BOOL)getServerNode:(NSString*)user pass:(NSString*)password error:(NSError* __autoreleasing*)error
{
    ODSession* session;
    NSError* err;

    _status = kODMNodeNotSet;
    session = [ODSession defaultSession];

    NSArray* arr = [session nodeNamesAndReturnError:&err];
    NSString* str = [NSString stringWithFormat:@"/LDAPv3/%@", _server];
    NSPredicate* nodePredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", str];

    NSArray* car = [arr filteredArrayUsingPredicate:nodePredicate];
    if (!car.count) {
        _domain = kODMProxyDirectoryServer;
    }

    if (_domain == kODMProxyDirectoryServer) {
        if (!user || !password || !_server) {
            [_delegate didRecieveStatusUpdate:kODMNodeNotAutenticatedProxy];
            return NO;
        }
        NSDictionary* settings = @{ ODSessionProxyAddress : _server,
                                    ODSessionProxyPort : @"0",
                                    ODSessionProxyUsername : user,
                                    ODSessionProxyPassword : password
        };

        session = [ODSession sessionWithOptions:settings error:&err];
        if (!session) {
            _status = kODMNodeNotAutenticatedProxy;
            return NO;
        }
        _node = [ODNode nodeWithSession:session name:@"/LDAPv3/127.0.0.1" error:&err];
        if (_node) {
            [_delegate didRecieveStatusUpdate:kODMNodeAuthenticatedProxy];
            _status = kODMNodeAuthenticatedProxy;
            return YES;
        }
        _status = kODMNodeNotAutenticatedProxy;
        return NO;
    }

    if (!session) {
        [ODManagerError errorWithCode:kODMerrODSessionError error:error];
        [_delegate didRecieveStatusUpdate:_status];
        return NO;
    }

    NSString* ds;
    if (_server) {
        if ([_server rangeOfString:@"LDAPv3"].location == NSNotFound) {
            ds = [NSString stringWithFormat:@"/LDAPv3/%@", _server];
        } else {
            ds = _server;
        }
        _node = [ODNode nodeWithSession:session name:ds error:&err];
    } else {
        _node = [ODNode nodeWithSession:session type:_domain error:&err];
    }

    if (err) {
        [ODManagerError errorWithCode:kODMerrWrongPassword error:error];
        [_delegate didRecieveStatusUpdate:_status];
        return NO;
    } else {
        _status = (_domain != kODMProxyDirectoryServer) ? kODMNodeNotAuthenticatedLocal : kODMNodeNotAutenticatedProxy;
    }

    [_delegate didRecieveStatusUpdate:_status];
    return YES;
}

- (OSStatus)authenticateWithUser:(NSString*)user password:(NSString*)password error:(NSError**)error
{
    BOOL authenticated = NO;
    _status = kODMNodeNotSet;
    if (!_node) {
        return _status;
    }

    if (!user || !password) {
        return kODMProxyDirectoryServer ? kODMNodeNotAutenticatedProxy : kODMNodeNotAuthenticatedLocal;
    };

    authenticated = [_node setCredentialsWithRecordType:nil
                                             recordName:user
                                               password:password
                                                  error:error];

    if (_domain == kODMProxyDirectoryServer) {
        _status = authenticated ? kODMNodeAuthenticatedProxy : kODMNodeNotAutenticatedProxy;
        [_delegate didRecieveStatusUpdate:_status];
    } else {
        _status = authenticated ? kODMNodeAuthenticatedLocal : kODMNodeNotAuthenticatedLocal;
        [_delegate didRecieveStatusUpdate:_status];
    }

    return _status;
}

@end
