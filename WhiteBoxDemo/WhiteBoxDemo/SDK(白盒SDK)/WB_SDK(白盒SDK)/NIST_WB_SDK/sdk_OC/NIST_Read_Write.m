//
//  NIST_Read_Write.m
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/11/1.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_Read_Write.h"

/* sdk_OC */
#import "NIST_WB_SDK_Header.h"

@interface NIST_Read_Write ()
@property (strong, nonatomic, readwrite) NSMutableDictionary * dict;
@end

@implementation NIST_Read_Write
#pragma mark - 单例
static NIST_Read_Write * nist_read_write = nil;
+ (NIST_Read_Write *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nist_read_write = [[NIST_Read_Write alloc]init];
    });
    return nist_read_write;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!nist_read_write)
    {
        nist_read_write = [super allocWithZone:zone];
    }
    return nist_read_write;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dict = [[NSMutableDictionary alloc]initWithContentsOfFile:NIST_PATH];
}

#pragma mark - 缓存数据
- (void)readWriteKey:(NSString *)key
               Value:(NSString *)value
{
    /* 字典判空 */
    if (self.dict == nil)
    {
        self.dict = [[NSMutableDictionary alloc]init];
    }
    
    /* 判空 */
    if (key == nil || value == nil)
    {
        NSLog(@"缓存出错");
        return;
    }
    NSLog(@"缓存数据成功");
    [self.dict setObject:value forKey:key];
    [self.dict writeToFile:NIST_PATH atomically:YES];
}

#pragma mark - 公钥版本
- (NSString *)pubkeyVersion
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_PUK_CERT_VERSION])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_PUK_CERT_VERSION])
    {
        NSLog(@"缓存的公钥版本数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_PUK_CERT_VERSION];
    return value;
}

#pragma mark - 签名公钥
- (NSString *)signPubkey
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_PUK_CERT_SIGN_PUBKEY])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_PUK_CERT_SIGN_PUBKEY])
    {
        NSLog(@"缓存的签名公钥数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_PUK_CERT_SIGN_PUBKEY];
    return value;
}

#pragma mark - 加密公钥
- (NSString *)encryptPubkey
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_PUK_CERT_ENCRYPT_PUBKEY])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_PUK_CERT_ENCRYPT_PUBKEY])
    {
        NSLog(@"缓存的加密公钥数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_PUK_CERT_ENCRYPT_PUBKEY];
    return value;
}

#pragma mark - 加密公钥的签名值
- (NSString *)encryptPubkeySign
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_PUK_CERT_SIGN_VALUE])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_PUK_CERT_SIGN_VALUE])
    {
        NSLog(@"缓存的加密公钥的签名值数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_PUK_CERT_SIGN_VALUE];
    return value;
}

#pragma mark - 设备特征码
- (NSString *)dfc
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_DEV_FEATURE_SIGNATURE])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_DEV_FEATURE_SIGNATURE])
    {
        NSLog(@"缓存的设备特征码数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_DEV_FEATURE_SIGNATURE];
    return value;
}

#pragma mark - 特征码哈希值DFV1
- (NSString *)dfv1
{    
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_DEV_FEATURE_DFV1])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_DEV_FEATURE_DFV1])
    {
        NSLog(@"缓存的特征码哈希值DFV1数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_DEV_FEATURE_DFV1];
    return value;
}

#pragma mark - 获取终端编号
- (NSString *)termId
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_TERM_ID_NUM])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_TERM_ID_NUM])
    {
        NSLog(@"缓存的终端编号数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_TERM_ID_NUM];
    return value;
}

#pragma mark - 获取终端编号签名
- (NSString *)termIdSign
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_TERM_ID_SIGN])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_TERM_ID_SIGN])
    {
        NSLog(@"缓存的终端编号签名数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_TERM_ID_SIGN];
    return value;
}

#pragma mark - 获取安全模块认证码ZCODE
- (NSString *)zcode
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_TERM_ID_ZCODE])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_TERM_ID_ZCODE])
    {
        NSLog(@"缓存的安全模块认证码ZCODE数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_TERM_ID_ZCODE];
    return value;
}

- (NSString *)session_id
{
    /* 字典判空 */
    if (self.dict == nil || [self.dict isKindOfClass:[NSNull class]] || self.dict.count == 0)
    {
        return 0;
    }
    if (![[self.dict allKeys] containsObject:FILE_SESSION_ID])
    {
        return 0;
    }
    if (![self.dict objectForKey:FILE_SESSION_ID])
    {
        NSLog(@"缓存的安全模块认证码session_id数据为空");
        return 0;
    }
    NSString * value = [self.dict objectForKey:FILE_SESSION_ID];
    return value;
}

#pragma mark - MLeaksFinder（内存泄漏检测工具）
- (BOOL)willDealloc
{
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf assertNotDealloc];
    });
    return YES;
}

- (void)assertNotDealloc
{
    NSAssert(NO, @"内存泄漏");
}

@end
