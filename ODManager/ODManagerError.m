//
//  ODManagerError.m
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


#import "ODManagerError.h"
static NSString *const errorDomain = @"com.eeaapps.odmanager";

@implementation ODManagerError
+(BOOL)errorWithCode:(OSStatus)code error:(NSError *__autoreleasing *)error{
    NSString *message = nil;
    NSBundle *bundel = [NSBundle bundleForClass:[self class]];
    NSString *tabel = @"ODManagerStrings";
    switch (code) {
        case kODMerrSuccess: return YES;
        case kODMerrCouldNotConnectToNode: {
            message = NSLocalizedStringFromTableInBundle(@"errNoNode", tabel, bundel, nil);
            break;
        }
        case kODMerrNoUserRecord: {
			message = NSLocalizedStringFromTableInBundle(@"errNoUserRecord", tabel, bundel, nil);
            break;
		}
        case kODMerrNoGroupRecord: {
			message = NSLocalizedStringFromTableInBundle(@"errNoGroupRecord", tabel, bundel, nil);
            break;
		}
        case kODMerrNoPresetRecord: {
			message = NSLocalizedStringFromTableInBundle(@"errNoPresetRecord", tabel, bundel, nil);
            break;
		}
        case kODMerrNoMatchingRecord: {
			message = NSLocalizedStringFromTableInBundle(@"errNoMatchingRecord", tabel, bundel, nil);
            break;
		}
        case kODMerrWrongPassword: {
			message = NSLocalizedStringFromTableInBundle(@"errWrongPassword", tabel, bundel, nil);
            break;
		}
        case kODMerrNoPasswordSupplied: {
			message = NSLocalizedStringFromTableInBundle(@"errNoPasswordSupplied", tabel, bundel, nil);
            break;
		}
        case kODMerrInvakidCredentials: {
			message = NSLocalizedStringFromTableInBundle(@"errInvalidCredentials", tabel, bundel, nil);
            break;
		}
        case kODMerrODSessionError: {
			message = NSLocalizedStringFromTableInBundle(@"errSessionError", tabel, bundel, nil);
            break;
		}
        case kODMerrNoDirectoryNode: {
			message = NSLocalizedStringFromTableInBundle(@"errNoDirectoryNode", tabel, bundel, nil);
            break;
		}
        case kODMerrCouldNotAddUser: {
			message = NSLocalizedStringFromTableInBundle(@"errCouldNotAddUser", tabel, bundel, nil);
            break;
		}
        case kODMerrUserAlreadyExists: {
			message = NSLocalizedStringFromTableInBundle(@"errUserAlreadyExists", tabel, bundel, nil);
            break;
		}
        case kODMerrCouldNotRemoveUser: {
			message = NSLocalizedStringFromTableInBundle(@"errCouldNotRemoveUser", tabel, bundel, nil);
            break;
		}
        case kODMerrCouldNotAddGroup: {
			message = NSLocalizedStringFromTableInBundle(@"errCouldNotAddGroup", tabel, bundel, nil);
            break;
		}
        case kODMerrCouldNotRemoveGroup: {
			message = NSLocalizedStringFromTableInBundle(@"errCouldNotRemoveGroup", tabel, bundel, nil);
            break;
		}
        case kODMerrIncompleteUserObject: {
			message = NSLocalizedStringFromTableInBundle(@"errUserObjectIncomplete", tabel, bundel, nil);
            break;
		}
        case kODMerrIncompleteGroupObject: {
			message = NSLocalizedStringFromTableInBundle(@"errGroupObjectIncomplete", tabel, bundel, nil);
            break;
		}
        default: {
			message = NSLocalizedStringFromTableInBundle(@"errDefault", tabel, bundel, nil);
		}
    }
    if(error)
        *error = [NSError errorWithDomain:errorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey:message}];
    return NO;
}


+(BOOL)errorWithCode:(OSStatus)code log:(NSError *__autoreleasing*)error{
    if(*error){
        NSError *err = *error;
        NSLog(@"%@",err.localizedDescription);
    }
    return [self errorWithCode:code error:error];
}

+(BOOL)errorWithMessage:(NSString *)message error:(NSError *__autoreleasing *)error{
    return [self errorWithMessage:message code:-1 error:error];
}

+(BOOL)errorWithMessage:(NSString *)message code:(OSStatus)code error:(NSError *__autoreleasing *)error{
    if(code == 0){
        return YES;
    }
    
    NSDictionary *userInfo = nil;
    if (message != nil) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    if(error)*error = [NSError errorWithDomain:errorDomain code:code userInfo:userInfo];
    return NO;
}

+(void)logError:(NSError*)error{
    NSLog(@"OpenDirectory Error: %@",error.localizedDescription);
}

@end
