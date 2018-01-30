//
//  NIST_WB_SDK_Header.h
//  WhiteBoxSDK(白盒SDK)
//
//  Created by 范云飞 on 2017/10/30.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#ifndef NIST_WB_SDK_Header_h
#define NIST_WB_SDK_Header_h

/* 获取沙盒路径 */
#define NIST_PATH  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NIST_WB_Models.plist"]

/* 用户名宏定义 */
#define user_id      @"fanyunfei"
/* 用户手机 */
#define mobile_phone @"15137162459"
/* 用户PIN码 */
#define user_pwd     @"111111"

/* sdk_C文件 */
#include "zalglib.h"
#include "ztype.h"


/* sdk_OC文件 */
#import "sm2alg.h"                  /* SM2,SM3,SM4算法 */
#import "NIST_WB_SDK.h"             /* SDK的业务处理 */
#import "NIST_Device_Info.h"        /* 获取设备信息 */
#import "NIST_UUID.h"               /* 获取设备唯一标示 */
#import "NIST_SSL.h"                /* 算法 */
#import "NIST_Read_Write.h"         /* 缓存数据 */
#import "NIST_Tool.h"               /* 字符转换工具 */

#endif /* NIST_WB_SDK_Header_h */
