//
//  ODSecureObjects.m
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

#import "ODSecureObjects.h"
#import <CommonCrypto/CommonDigest.h>

#pragma mark - User
@implementation ODUser

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _userName  = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"userName"];
        _firstName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"firstName"];
        _lastName  = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lastName"];
        _passWord  = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"passWord"];
        _uid       = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"uid"];
        
        _primaryGroup = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"primaryGroup"];
        _emailDomain = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"emailDomain"];
        _keyWord = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"keyWord"];
        
        _userPreset = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"userPreset"];
        _userShell = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"userShell"];
        _sharePoint = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"sharePoint"];
        _sharePath = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"sharePath"];
        _nfsPath = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"nfsPath"];
        _homeDirectory = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"homeDirectory"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_userName forKey:@"userName"];
    [aEncoder encodeObject:_firstName forKey:@"firstName"];
    [aEncoder encodeObject:_lastName forKey:@"lastName"];
    [aEncoder encodeObject:_passWord forKey:@"passWord"];
    [aEncoder encodeObject:_uid forKey:@"uid"];
    
    [aEncoder encodeObject:_primaryGroup forKey:@"primaryGroup"];
    [aEncoder encodeObject:_emailDomain forKey:@"emailDomain"];
    
    [aEncoder encodeObject:_userShell forKey:@"userShell"];
    [aEncoder encodeObject:_sharePoint forKey:@"sharePoint"];
    [aEncoder encodeObject:_sharePath forKey:@"sharePath"];
    [aEncoder encodeObject:_nfsPath forKey:@"nfsPath"];
    [aEncoder encodeObject:_homeDirectory forKey:@"homeDirectory"];

    [aEncoder encodeObject:_keyWord forKey:@"keyWord"];
    [aEncoder encodeObject:_userPreset forKey:@"userPreset"];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"username: %@",_userName];
}
-(NSString*)homeDirectory{
    NSString* path;
    if(_homeDirectory){
        return _homeDirectory;
    }
    else if(_sharePoint && _userName){
        path = !_sharePath ? _userName:[_sharePath stringByAppendingPathComponent:_userName];
        return [NSString stringWithFormat:@"<home_dir><url>%@</url><path>%@</path></home_dir>",_sharePoint,path];
    }
    return nil;
}


@end

#pragma mark - User List
@implementation ODRecordList
-(id)init{
    self = [super init];
    if(self){
        _users = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    NSSet *whiteList = [NSSet setWithObjects:[NSArray class],[ODUser class],[NSString class], nil];
    self = [super init];
    if (self) {
        _users = [aDecoder decodeObjectOfClasses: whiteList forKey:@"users"];
        _groups = [aDecoder decodeObjectOfClasses: whiteList forKey:@"groups"];
        _filter = [aDecoder decodeObjectOfClass: [NSString class] forKey:@"filter"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_users forKey:@"users"];
    [aEncoder encodeObject:_groups forKey:@"groups"];
    [aEncoder encodeObject:_filter forKey:@"filter"];
}
@end

#pragma  mark - Group
@implementation ODGroup
- (id)initWithCoder:(NSCoder*)aDecoder {
    NSSet *whiteList = [NSSet setWithObjects:[NSArray class],[NSDictionary class],[NSString class], nil];
    self = [super init];
    if (self) {
        _groupName = [aDecoder decodeObjectOfClasses: whiteList forKey:@"groupName"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_groupName forKey:@"groupName"];
    
}
@end


#pragma mark -  Preset
@implementation ODPreset
- (id)initWithCoder:(NSCoder*)aDecoder {
    NSSet *whiteList = [NSSet setWithObjects:[NSArray class],[NSDictionary class],[NSString class], nil];
    self = [super init];
    if (self) {
        _presetName = [aDecoder decodeObjectOfClasses: whiteList forKey:@"presetName"];
        _userShell =[aDecoder decodeObjectOfClasses: whiteList forKey:@"userShell"];
        _nfsPath =[aDecoder decodeObjectOfClasses: whiteList forKey:@"nfsPath"];
        _sharePath=[aDecoder decodeObjectOfClasses: whiteList forKey:@"sharePath"];
        _sharePoint=[aDecoder decodeObjectOfClasses: whiteList forKey:@"sharePoint"];
        _primaryGroup=[aDecoder decodeObjectOfClasses: whiteList forKey:@"primaryGroup"];
        _mcxFlags=[aDecoder decodeObjectOfClasses: whiteList forKey:@"mcxFlags"];
        _mcxSettings=[aDecoder decodeObjectOfClasses: whiteList forKey:@"mcxSettings"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_presetName forKey:@"presetName"];
    [aEncoder encodeObject:_userShell forKey:@"userShell"];
    [aEncoder encodeObject:_nfsPath forKey:@"nfsPath"];
    [aEncoder encodeObject:_sharePath forKey:@"sharePath"];
    [aEncoder encodeObject:_sharePoint forKey:@"sharePoint"];
    [aEncoder encodeObject:_primaryGroup forKey:@"primaryGroup"];
    [aEncoder encodeObject:_mcxFlags forKey:@"mcxFlags"];
    [aEncoder encodeObject:_mcxSettings forKey:@"mcxSettings"];
}
@end

#pragma mark - Server
@implementation ODServer

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        _directoryServer = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"directoryServer"];
        _directoryDomain = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"directoryDomain"];
        _diradminName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"diradminName"];
        _diradminPass = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"diradminPass"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_directoryServer forKey:@"directoryServer"];
    [aEncoder encodeObject:_directoryDomain forKey:@"directoryDomain"];
    [aEncoder encodeObject:_diradminName forKey:@"diradminName"];
    [aEncoder encodeObject:_diradminPass forKey:@"diradminPass"];
}
@end

@implementation NSString (uuidWithLength)
-(NSString *)uuidWithLength:(int)lenght{
    unsigned char digest[16];
    NSString *uuid;
    
    CC_MD5( self.UTF8String , (int)self.length, digest ); // This is the md5 call
    
    NSMutableString *md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [md5 appendFormat:@"%02x", digest[i]];
    
    NSString *noLetters = [[md5 componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet]
                             invertedSet]] componentsJoinedByString:@""];
    
    NSString *noZeros = [noLetters stringByReplacingOccurrencesOfString:@"0" withString:@""];
    uuid = [noZeros substringFromIndex:noZeros.length-lenght];
    
    return  uuid;
}
@end

