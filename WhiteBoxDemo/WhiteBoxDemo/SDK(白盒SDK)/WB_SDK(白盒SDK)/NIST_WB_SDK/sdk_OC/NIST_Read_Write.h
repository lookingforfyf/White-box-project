//
//  NIST_Read_Write.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/11/1.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.数据的读写类
 2.本类中返回NNString类型的方法中，都是16进制字符串
 3.本类中存储的都是16进制字符串
 ***********************************************/
#import <Foundation/Foundation.h>

#pragma mark - 公钥文件（四行：版本号\n签名公钥\n加密公钥\n对加密公钥的签名值
#define FILE_PUK_CERT_VERSION           @"FILE_PUK_CERT_VERSION"           /* 缓存版本号的key */
#define FILE_PUK_CERT_SIGN_PUBKEY       @"FILE_PUK_CERT_SIGN_PUBKEY"       /* 缓存签名公钥的key */
#define FILE_PUK_CERT_ENCRYPT_PUBKEY    @"FILE_PUK_CERT_ENCRYPT_PUBKEY"    /* 缓存加密公钥的key */
#define FILE_PUK_CERT_SIGN_VALUE        @"FILE_PUK_CERT_SIGN_VALUE"        /* 缓存对加密公钥的签名值的key */

#pragma mark - 设备特征文件（两行：特征码\n特征码哈希值DFV1
#define FILE_DEV_FEATURE_SIGNATURE      @"FILE_DEV_FEATURE_SIGNATURE"      /* 缓存特征码的key */
#define FILE_DEV_FEATURE_DFV1           @"FILE_DEV_FEATURE_DFV1"           /* 缓存特征码哈希值DFV1的key */

#pragma mark - 终端编号文件（三行：终端编号\n终端编号签名\n安全模块认证码ZCODE）
#define FILE_TERM_ID_NUM                @"FILE_TERM_ID_NUM"                /* 缓存终端编号的key */
#define FILE_TERM_ID_SIGN               @"FILE_TERM_ID_SIGN"               /* 缓存终端编号签名的key */
#define FILE_TERM_ID_ZCODE              @"FILE_TERM_ID_ZCODE"              /* 缓存安全模块认证码ZCODE的key*/

#pragma mark - 动态白盒
#define FILE_DYN_ZALG                   @"DYN-ZALG"                        /* 缓存动态白盒的key */

#pragma mark - session_id
#define FILE_SESSION_ID                 @"SESSION_ID"                      /* 缓存session_id的key */

@interface NIST_Read_Write : NSObject
#pragma mark -
/**
 单例
 
 @return NIST_WB_SDK
 */
+ (NIST_Read_Write *)shareInstance;

#pragma mark -
/**
 缓存数据

 @param key 缓存的key
 @param value 缓存的value
 */
- (void)readWriteKey:(NSString *)key
               Value:(NSString *)value;

#pragma mark - 公钥文件
/**
 获取公钥版本号

 @return 获取版本号
 */
- (NSString *)pubkeyVersion;
/**
 获取签名公钥

 @return 获取签名公钥
 */
- (NSString *)signPubkey;
/**
 获取加密公钥
 
 @return 获取加密公钥
 */
- (NSString *)encryptPubkey;
/**
 获取加密公钥的签名值

 @return 加密公钥的签名值
 */
- (NSString *)encryptPubkeySign;
#pragma mark - 设备特征文件
/**
 获取DFC

 @return dfc
 */
- (NSString *)dfc;
/**
 获取dfv1：SM3(DFC)

 @return SM3(DFC)
 */
- (NSString *)dfv1;

#pragma mark - 终端编号文件
/**
 获取终端编号

 @return termId
 */
- (NSString *)termId;
/**
 获取终端编号签名

 @return termIdSign
 */
- (NSString *)termIdSign;
/**
 安全模块认证码ZCODE

 @return zcode
 */
- (NSString *)zcode;

#pragma mark - SESSION_ID
/**
 获取session_id

 @return session_id
 */
- (NSString *)session_id;

@end
