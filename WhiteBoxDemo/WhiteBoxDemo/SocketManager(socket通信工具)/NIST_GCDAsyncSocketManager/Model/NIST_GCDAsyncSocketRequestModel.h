//
//  NIST_GCDAsyncSocketRequestModel.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/26.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.请求报文模型
 *****************************************/
#import <JSONModel/JSONModel.h>

@interface NIST_GCDAsyncSocketRequestModel : JSONModel
@property (copy, nonatomic) NSString       <Optional> * MSG_VERSION;         /* 协议版本号 */
@property (copy, nonatomic) NSString       <Optional> * MSG_TYPE;            /* 报文类型 */
@property (copy, nonatomic) NSString       <Optional> * REQ_SYSTEM;          /* 请求系统标识 */
@property (copy, nonatomic) NSString       <Optional> * REQ_SYSTEM_CODE;     /* 请求系统编号 */
@property (copy, nonatomic) NSString       <Optional> * SVR_SYSTEM;          /* 服务系统标识 */
@property (copy, nonatomic) NSString       <Optional> * SVR_SYSTEM_CODE;     /* 服务系统编号 */
@property (copy, nonatomic) NSString       <Optional> * REQ_DATE;            /* 发起请求日期 */
@property (copy, nonatomic) NSString       <Optional> * REQ_TIME;            /* 发起请求时间 */
@property (copy, nonatomic) NSString       <Optional> * REQ_DEALNO;          /* 请求端流水号 */
@property (copy, nonatomic) NSString       <Optional> * SVR_CLASS;           /* 请求服务类型 */
@property (copy, nonatomic) NSString       <Optional> * SVR_CODE;            /* 请求服务代码 */
@property (strong, nonatomic) NSDictionary <Optional> * MSG_BODY;            /* 请求体 */
@property (copy, nonatomic) NSString       <Optional> * MAC;                 /* 报文认证码 */
@end
