//
//  NIST_SSL.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/12/12.
//  Copyright © 2017年 范云飞. All rights reserved.
//



/***********************************************
 本类主要负责：
 1.基于国密算法标准的方法类
 2.Z系列算法
 3.本类中返回NNString类型的方法中，都是16进制字符串
 ***********************************************/
#import <Foundation/Foundation.h>

/* sdk_C */
#include "ztype.h"
#include "zalglib.h"

/* sdk_OC */
#include "NIST_WB_SDK_Header.h"

@interface NIST_SSL : NSObject
#pragma mark -
/**
 单例
 
 @return NIST_SSL
 */
+ (NIST_SSL *)shareInstance;

#pragma mark -
/**
 SM3算法对数据进行HASH计算

 @param msg msg
 @return hash
 */
+ (NSString *)sm3:(NSString *)msg;

#pragma mark -
/**
 SM2算法椭圆曲线参数初始化
 */
+ (void)sm2_init;
/**
 生成SM2算法公私密钥对[d、G(x,y)]
 
 @param rand 可选随机数
 @param dict 输出公私密钥对[d、G(x,y)]
 @return 0成功 !0失败
 */
+ (int)sm2_keypair_generation:(NSString *)rand
                          dic:(NSMutableDictionary *__autoreleasing *)dict;
/**
 预处理由公钥计算ZA
 
 @param px 公钥Gx
 @param py 公钥Gy
 @param za 输出
 @return 0成功 !0失败
 */
+ (int)sm2_sign_pre:(NSString *)px
                 py:(NSString *)py
                 za:(NSString * __autoreleasing *)za;
/**
 SM2算法私钥签名
 
 @param privkey 私钥d
 @param za 预处理值
 @param msg 消息
 @param rand 可选随机数
 @param dict 输出签名R、S
 @return 0成功 !0失败
 */
+ (int)sm2_sign:(NSString *)privkey
             za:(NSString *)za
            msg:(NSString *)msg
           rand:(NSString *)rand
           dict:(NSMutableDictionary * __autoreleasing *)dict;
/**
 SM2算法公钥验证签名
 
 @param px 公钥Gx
 @param py 公钥Gy
 @param za 预处理
 @param msg 消息
 @param signR 签名R
 @param signS 签名S
 @return 0成功 !0失败
 */
+ (int)sm2_verify:(NSString *)px
               py:(NSString *)py
               za:(NSString *)za
              msg:(NSString *)msg
            signR:(NSString *)signR
            signS:(NSString *)signS;
/**
 SM2算法公钥加密
 
 @param px 公钥Gx
 @param py 公钥Gy
 @param plain 明文
 @param rand 可选随机数
 @param cipher 输出密文
 @return 0成功 !0失败
 */
+ (int)sm2_encrypt:(NSString *)px
                py:(NSString *)py
             plain:(NSString *)plain
              rand:(NSString *)rand
            cipher:(NSString * __autoreleasing *)cipher;
/**
 SM2算法私钥解密
 
 @param privkey 私钥d
 @param cipher 密文
 @param plain 输出明文
 @return 0成功 !0失败
 */
+ (int)sm2_decrypt:(NSString *)privkey
            cipher:(NSString *)cipher
             plain:(NSString * __autoreleasing *)plain;

#pragma mark -
/**
 SM4算法加密
 
 @param plain 明文
 @param cipher 密文
 @param key 密钥
 @return 0成功 !0失败
 */
+ (int)sm4_encrypt:(NSString *)plain
            cipher:(NSString * __autoreleasing *)cipher
               key:(NSString *)key;
/**
 SM4算法解密
 
 @param cipher 密文
 @param plain 明文
 @param key 密钥
 @return 0成功 !0失败
 */
+ (int)sm4_decrypt:(NSString *)cipher
             plain:(NSString * __autoreleasing *)plain
               key:(NSString *)key;

#pragma mark -
/**
 去盐算法
 
 @param salt salt
 @param data 加盐后的数据
 @param ouput 输出去盐后的数据
 @return 0表示成功，非0表示失败
 */
+ (int)daSalt:(NSString *)salt
         data:(NSString *)data
        ouput:(NSString * __autoreleasing *)ouput;

#pragma mark -
/**
 ZTA加密
 
 @param plaintxt 明文
 @param ciphertxt 输出密文
 @return 0表示成功，非0表示失败
 */
+ (int)encryptZTA:(NSString *)plaintxt
        ciphertxt:(NSString * __autoreleasing *)ciphertxt;
/**
 ZTB解密
 
 @param ciphertxt 密文
 @param plaintxt 明文
 @return 0表示成功，非0表示失败
 */
+ (int)decryptZTB:(NSString *)ciphertxt
         plaintxt:(NSString * __autoreleasing *)plaintxt;

#pragma mark -
/**
 ZUA加密
 
 @param plaintxt 明文
 @param ciphertxt 输出密文
 @return 0表示成功，非0表示失败
 */
+ (int)encryptZUA:(NSString *)plaintxt
        ciphertxt:(NSString * __autoreleasing *)ciphertxt;
/**
 ZUB解密
 
 @param ciphertxt 密文
 @param plaintxt 明文
 @return 0表示成功，非0表示失败
 */
+ (int)decryptZUB:(NSString *)ciphertxt
         plaintxt:(NSString * __autoreleasing *)plaintxt;

#pragma mark -
/**
 ZSA加密
 
 @param plaintxt 明文
 @param ciphertxt 密文
 @return 0表示成功，非0表示失败
 */
+ (int)encryptZSA:(NSString *)plaintxt
        ciphertxt:(NSString * __autoreleasing *)ciphertxt;
/**
 ZSB解密
 
 @param ciphertxt 密文
 @param plaintxt 明文
 @return 0表示成功，非0表示失败
 */
+ (int)decryptZSB:(NSString *)ciphertxt
         plaintxt:(NSString * __autoreleasing *)plaintxt;

#pragma mark -
/**
 ZWA加密
 
 @param plaintxt 明文
 @param ciphertxt 密文
 @return 0表示成功，非0表示失败
 */
+ (int)encryptZWA:(NSString *)plaintxt
        ciphertxt:(NSString * __autoreleasing *)ciphertxt;
/**
 ZWB解密
 
 @param ciphertxt 密文
 @param plaintxt 明文
 @return 0表示成功，非0表示失败
 */
+ (int)decryptZWB:(NSString *)ciphertxt
         plaintxt:(NSString * __autoreleasing *)plaintxt;

#pragma mark -
/**
 计算zcode

 @param data 源数据
 @param zcode zcode
 @return 0表示成功，非0表示失败
 */
+ (int)data:(NSString *)data
      zcode:(NSString * __autoreleasing *)zcode;
@end
