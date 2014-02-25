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

-(id)initWithDomain:(int)domain{
    self = [super init];
    if(self){
        _domain = domain;
    }
    return self;
}

-(id)initWithServer:(NSString *)server domain:(int)domain{
    self = [super init];
    if(self){
        _server = server;
        _domain = domain;
    }
    return self;
}

-(ODNode*)getServerNode:(NSString *)user pass:(NSString *)password error:(NSError *__autoreleasing *)error{
    ODSession *session;
    ODNode *node;
    OSStatus status = kODMNodeNotSet;
    NSError *err;
    if(!_domain)_domain = kODMDefaultDomain;
    
    if(_domain == kODMProxyDirectoryServer){
        if(!user || !password || !_server){
            [_delegate didRecieveStatusUpdate:kODMNodeNotAutenticatedProxy];
            return nil;
        }
        NSDictionary *settings = @{ODSessionProxyAddress:_server,
                                   ODSessionProxyPort:@"0",
                                   ODSessionProxyUsername:user,
                                   ODSessionProxyPassword:password
                                   };
        
        session = [ODSession sessionWithOptions:settings error:&err];
        if(!session){
            return nil;
        }
        node = [ODNode nodeWithSession:session name:@"/LDAPv3/127.0.0.1" error:&err];
        if(node){
            [_delegate didRecieveStatusUpdate:kODMNodeAuthenticatedProxy];
        }
        return node;
    }else{
        session = [ODSession defaultSession];
    }
    
    if(!session){
        [ODManagerError errorWithCode:kODMerrODSessionError error:error];
        [_delegate didRecieveStatusUpdate:status];
        return nil;
    }
    
    NSString* ds;
    if(_server){
        if([_server rangeOfString:@"LDAPv3"].location==NSNotFound){
            ds = [NSString stringWithFormat:@"/LDAPv3/%@",_server];
        }else{
            ds = _server;
        }
        node = [ODNode nodeWithSession:session name:ds error:&err];
    }else{
        node = [ODNode nodeWithSession:session type:_domain error:&err];
    }
    
    if(err){
        [ODManagerError errorWithCode:kODMerrWrongPassword error:error];
        [_delegate didRecieveStatusUpdate:status];
        return nil;
    }else{
        status = (_domain != kODMProxyDirectoryServer) ? kODMNodeNotAuthenticatedLocal:kODMNodeNotAutenticatedProxy;
    }
    
    [_delegate didRecieveStatusUpdate:status];
    return node;
}


-(OSStatus)authenticateToNode:(ODNode*)node user:(NSString*)user password:(NSString*)password error:(NSError *__autoreleasing *)error{
    BOOL authenticated = NO;
    OSStatus status = kODMNodeNotSet;
    if(!node){
        return status;
    }
    
    if(!user || !password){
        return kODMProxyDirectoryServer ? kODMNodeNotAutenticatedProxy:kODMNodeNotAuthenticatedLocal;
    };
    
    authenticated = [node setCredentialsWithRecordType:nil
                                            recordName:user
                                              password:password
                                                 error:error];
    
    if (_domain == kODMProxyDirectoryServer){
        status = authenticated ? kODMNodeAuthenticatedProxy:kODMNodeNotAutenticatedProxy;
        [_delegate didRecieveStatusUpdate:status];
    }
    else{
        status = authenticated ? kODMNodeAuthenticatedLocal:kODMNodeNotAuthenticatedLocal;
        [_delegate didRecieveStatusUpdate:status];
    }
    
    return status;
}



@end
