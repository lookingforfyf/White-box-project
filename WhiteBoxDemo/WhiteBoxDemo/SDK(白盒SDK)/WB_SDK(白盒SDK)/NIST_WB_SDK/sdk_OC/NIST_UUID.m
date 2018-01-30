//
//  NIST_UUID.m
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/10/31.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_UUID.h"

#define UUID_KEYCHAIN @"UUIDKeyChain"

@implementation NIST_UUID
#pragma mark - 单例
+ (NIST_UUID *)sharedInstance
{
    static NIST_UUID * instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

#pragma mark - 获取并保存UUID
+ (NSString *)obtainUUID
{
    NSMutableDictionary * UUIDKeyChain = (NSMutableDictionary *)[self load:UUID_KEYCHAIN];
    NSString * uuid = [NSString string];
    if (![UUIDKeyChain objectForKey:@"uuidkey"])
    {
        uuid = [NIST_UUID getUUIDString];
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:uuid forKey:@"uuidkey"];
        [NIST_UUID save:UUID_KEYCHAIN data:dic];
    }
    else
    {
        uuid = [UUIDKeyChain objectForKey:@"uuidkey"];
    }
    return uuid;
}

+ (id)load:(NSString *)service
{
    id ret = nil;
    NSMutableDictionary * keychainQuery = [NIST_UUID getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
    {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (NSString *)getUUIDString
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString * uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

+ (void)save:(NSString *)service data:(id)data
{
    NSMutableDictionary * keychainQuery = [NIST_UUID getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,nil];
}

#pragma mark - 删除UUID
- (void)deleteUUID
{
    NSMutableDictionary * keychainQuery = [NIST_UUID getKeychainQuery:UUID_KEYCHAIN];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}
@end
