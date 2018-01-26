//
//  NIST_GCDErrorManager.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.自定义的服务器和SDK内部的错误信息，
   只是临时写的，具体到项目中调整
 *****************************************/
#import <Foundation/Foundation.h>

@interface NIST_GCDErrorManager : NSObject

/* 服务器定义错误信息 */
#define NIST_REQUEST_TIMEOUT                @"请求超时"
#define NIST_REQUEST_PARAM_ERROR            @"入参错误"
#define NIST_REQUEST_ERROR                  @"请求失败"
#define NIST_SERVER_MAINTENANCE_UPDATES     @"用户状态丢失"
#define NIST_AUTHAPPRAISAL_FAILED           @"Token 失效"

/* SDK内定义错误信息 */
#define NIST_NETWORK_DISCONNECTED           @"网络断开"
#define NIST_LOCAL_REQUEST_TIMEOUT          @"本地请求超时"
#define NIST_XML_PARSE_ERROR                @"XML 解析错误"
#define NIST_LOCAL_PARAM_ERROR              @"本地入参错误"


/**
 错误信息

 @param errorCode 状态码
 @return NSError
 */
+ (NSError *)errorWithErrorCode:(NSInteger)errorCode;

/**
 服务端错误信息

 @param errorCode 状态码
 @param errorMsg 错误信息
 @return NSError
 */
+ (NSError *)errorWithErrorCode:(NSInteger)errorCode
                       errorMsg:(NSString *)errorMsg;

@end
