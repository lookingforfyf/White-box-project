//
//  NIST_GCDAsyncSocketResponseModel.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/26.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.响应报文模型,借助第三方工具XMLReader 生成的json数据，
   和请求报文格式不同
 2.获取了响应报文以后，置于怎么处理，就和服务端无关了
 *****************************************/
#import <JSONModel/JSONModel.h>
#import "NIST_GCDAsyncSocketRequestElementModel.h"

@interface REQ_TIME :NIST_GCDAsyncSocketRequestElementModel

@end

@interface SVR_CODE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface SVR_SYSTEM_CODE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface REQ_DEALNO :NIST_GCDAsyncSocketRequestElementModel

@end

@interface REQ_SYSTEM_CODE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface SVR_SYSTEM :NIST_GCDAsyncSocketRequestElementModel

@end

@interface MAC :NIST_GCDAsyncSocketRequestElementModel

@end

@interface DESCRIPTION :NIST_GCDAsyncSocketRequestElementModel

@end

@interface RET_CODE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface MSG_TYPE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface REQ_DATE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface SVR_DEALNO :NIST_GCDAsyncSocketRequestElementModel

@end

@interface RESP_DATE :NIST_GCDAsyncSocketRequestElementModel

@end

@interface SVR_CLASS :NIST_GCDAsyncSocketRequestElementModel

@end

@interface REQ_SYSTEM :NIST_GCDAsyncSocketRequestElementModel

@end

@interface RESP_TIME :NIST_GCDAsyncSocketRequestElementModel

@end

@interface PUKEY :NIST_GCDAsyncSocketRequestElementModel


@end

@interface KEY_INDEX :NIST_GCDAsyncSocketRequestElementModel


@end

@interface PUK_CODING :NIST_GCDAsyncSocketRequestElementModel

@end

@interface RESP_DATA:NIST_GCDAsyncSocketRequestElementModel

@end

@interface MSG_BODY :JSONModel

//@property (nonatomic , strong) PUKEY               * PUKEY;
//@property (nonatomic , strong) KEY_INDEX           * KEY_INDEX;
//@property (nonatomic , strong) PUK_CODING          * PUK_CODING;
@property (nonatomic , copy) NSString           <Optional> * desc;
@property (nonatomic , strong) RESP_DATA        <Optional> * RESP_DATA;

@end

@interface MSG_VERSION :NIST_GCDAsyncSocketRequestElementModel

@end

@interface NIST_MESSAGE :JSONModel
@property (nonatomic , strong) REQ_TIME         <Optional> * REQ_TIME;           /* 发起请求的时间 */
@property (nonatomic , strong) SVR_CODE         <Optional> * SVR_CODE;           /* 请求服务代码 */
@property (nonatomic , strong) SVR_SYSTEM_CODE  <Optional> * SVR_SYSTEM_CODE;    /* 服务系统编号 */
@property (nonatomic , strong) REQ_DEALNO       <Optional> * REQ_DEALNO;         /* 请求端流水号 */
@property (nonatomic , strong) REQ_SYSTEM_CODE  <Optional> * REQ_SYSTEM_CODE;    /* 请求系统编号 */
@property (nonatomic , strong) SVR_SYSTEM       <Optional> * SVR_SYSTEM;         /* 服务系统标识 */
@property (nonatomic , strong) MAC              <Optional> * MAC;                /* 报文认证码 */
@property (nonatomic , strong) DESCRIPTION      <Optional> * DESCRIPTION;        /* 响应码描述 */
@property (nonatomic , strong) RET_CODE         <Optional> * RET_CODE;           /* 响应码 */
@property (nonatomic , strong) MSG_TYPE         <Optional> * MSG_TYPE;           /* 报文类型 */
@property (nonatomic , strong) REQ_DATE         <Optional> * REQ_DATE;           /* 发起请求日期 */
@property (nonatomic , strong) SVR_DEALNO       <Optional> * SVR_DEALNO;         /* 服务端流水号 */
@property (nonatomic , strong) RESP_DATE        <Optional> * RESP_DATE;          /* 处理日期 */
@property (nonatomic , strong) SVR_CLASS        <Optional> * SVR_CLASS;          /* 请求服务类型 */
@property (nonatomic , strong) REQ_SYSTEM       <Optional> * REQ_SYSTEM;         /* 请求系统标识 */
@property (nonatomic , strong) RESP_TIME        <Optional> * RESP_TIME;          /* 处理时间 */
@property (nonatomic , strong) MSG_BODY         <Optional> * MSG_BODY;           /* 响应Body */
@property (nonatomic , copy) NSString           <Optional> * text;               /* 协议描述 */
@property (nonatomic , strong) MSG_VERSION      <Optional> * MSG_VERSION;        /* 协议版本号 */

@end

@interface NIST_GCDAsyncSocketResponseModel :JSONModel

@property (nonatomic , strong) NIST_MESSAGE     <Optional> * NIST_MESSAGE;

@end
