//
//  NIST_Device_Info.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/10/31.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.获取设备信息的类
 2.本类中返回的字符串全部为普通字符串
 ***********************************************/
#import <Foundation/Foundation.h>

@interface NIST_Device_Info : NSObject

#pragma mark -
/**
 单例
 
 @return NIST_WB_SDK
 */
+ (NIST_Device_Info *)shareInstance;

#pragma mark - 
/**
 获取系统平台

 @return NSString
 */
+ (NSString *)getSystemPlatform;

#pragma mark -
/**
 获取设备型号

 @return NSString
 */
+ (NSString *)getDeviceModel;

#pragma mark -
/**
 获取固件版本

 @return NSString
 */
+ (NSString *)getFirmwareVersion;

#pragma mark -
/**
 获取设备序列号

 @return NSString
 */
+ (NSString *)getDeviceSerialNumber;

#pragma mark -
/**
 获取CPU型号

 @return NSString
 */
+ (NSString *)getCPUModel;

#pragma mark -
/**
 获取GPU型号(目前获取不到)

 @return NSString
 */
+ (NSString *)getGPUModel;

#pragma mark -
/**
 获取Mac地址

 @return NSString
 */
+ (NSString *)getMACAddress;

#pragma mark -
/**
 获取分辨率

 @return NSString
 */
+ (NSString *)getResolution;

#pragma mark -
/**
 获取基带版本（不支持）

 @return NSString
 */
+ (NSString *)getBasebandVersion;

#pragma mark -
/**
 获取SIM卡序列号（不支持）

 @return NSString
 */
+ (NSString *)getSIMCardSerialNumber;

#pragma mark -
/**
 获取手机号（不支持）

 @return NSString
 */
+ (NSString *)gettelephoneNumber;

#pragma mark -
/**
 获取设备IP

 @return NSString
 */
+ (NSString *)getIPAddress;

#pragma mark -
/**
 获取UUID

 @return NSString
 */
+ (NSString *)getUUID;

@end
