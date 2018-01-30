//
//  NIST_Tool.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/11/1.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.数据类型转化工具
 2.数据填充
 ***********************************************/
#import <Foundation/Foundation.h>

@interface NIST_Tool : NSObject

#pragma mark -
/**
 十六进制字符串转换为普通字符串的
 
 @param hexString 16进制字符串
 @return 普通字符串
 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

/**
 普通字符串转换为十六进制字符串
 
 @param string 普通字符串
 @return 十六进制字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string;

#pragma mark -
/**
 NSString转化为NSData
 
 @param string NSString
 @return NSData
 */
+ (NSData *)nsdataFromString:(NSString *)string;

/**
 NSData转化为NSString
 
 @param data NSData
 @return NSString
 */
+ (NSString *)stringFromNSData:(NSData *)data;

#pragma mark -
/**
 NSString转化为Byte数组
 
 @param string NSString
 @return Byte
 */
+ (Byte *)byteFromString:(NSString *)string;

/**
 Byte数组转化为NSString
 
 @param byte Byte
 @param len 长度
 @return NSString
 */
+ (NSString *)stringFromByte:(Byte *)byte
                         len:(NSInteger)len;

#pragma mark -
/**
 十六进制字符串转十进制
 
 @param hexStr HexString
 @return decimal
 */
- (NSInteger)decimalFromHexStr:(NSString *)hexStr;

/**
 十进制转十六进制字符串
 
 @param decimal decimal
 @return HexString
 */
- (NSString *)hexStrFromDecimal:(NSInteger)decimal;

#pragma mark -
/**
 int -> NSData(4个字节)
 
 @param d int
 @return NSData
 */
+ (NSData *)sndataFromInt:(int)d;

/**
 NSData -> int(4个字节)
 
 @param intData intData
 @return int
 */
+ (int)intFromNSData:(NSData *)intData;

#pragma mark -
/**
 int ->Hexstring

 @param val int
 @return Hexstring
 */
+ (NSString *)hexFromInt:(NSInteger)val;

#pragma mark -
/**
 hexString ->NSData

 @param hexString 16进制字符串
 @return NSData
 */
+ (NSData *)nsdataFromHexString:(NSString *)hexString;

/**
 NSData -> hexString

 @param data NSData
 @return hexString
 */
+ (NSString *)hexStringFromNSData:(NSData *)data;

#pragma mark -
/**
 uint8_t -> NSData

 @param val uint8_t
 @return NSData
 */
+ (NSData *)nsdataFromUInt8:(uint8_t)val;

/**
 NSData -> uint8_t

 @param fdata NSData
 @return uint8_t
 */
+ (uint8_t)uint8FromNSData:(NSData *)fdata;

#pragma mark -
/**
 uint16_t -> NSData

 @param val uint16_t
 @return NSData
 */
+ (NSData *)nsdataFromUInt16:(uint16_t)val;

/**
 NSData -> uint16_t

 @param fData NSData
 @return uint16_t
 */
+ (uint16_t)uint16FromNSData:(NSData *)fData;

#pragma mark -
/**
 uint32_t -> NSData

 @param val uint32_t
 @return NSData
 */
+ (NSData *)nsdataFromUInt32:(uint32_t)val;

/**
 NSData -> uint32_t

 @param fData NSData
 @return uint32_t
 */
+ (uint32_t)uint32FromNSData:(NSData *)fData;

#pragma mark -
/**
 uint64_t -> NSData

 @param val uint64_t
 @return NSData
 */
+ (NSData *)nsdataFromUInt64:(uint64_t)val;

/**
 NSData -> uint64_t

 @param fData NSData
 @return uint64_t
 */
+ (uint64_t)uint64FromNSData:(NSData *)fData;

#pragma mark -
/**
 大小端转换

 @param data <#data description#>
 @param dlen <#dlen description#>
 */
void big_endian(unsigned char* data, int dlen);

#pragma mark -
/**
 将字符串左侧的padding全部剔除

 @param str str
 @param padding padding
 @return 剔除padding后的str
 */
+ (NSString *)leftTrimString:(NSString *)str
                     padding:(NSString *)padding;

#pragma mark -
/**
 将字符串填充为CNT的整数倍(CNT可以为任何整数)

 @param strBuffer strBuffer
 @param cnt cnt
 @param padding padding
 @return 填充后的strBuffer
 */
+ (NSMutableString *)stringPadding:(NSMutableString *)strBuffer
                               cnt:(int)cnt
                           padding:(NSString *)padding;
@end
