//
//  NIST_GCDAsyncSocketCommunicationManager.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.根据具体业务需求处理回调数据
 *****************************************/
#import <Foundation/Foundation.h>

/* socket连接配置 */
#import "NIST_GCDConnectConfig.h"


/**
 *  业务类型
 */
typedef NS_ENUM(NSInteger, NIST_GCDRequestType)
{
    NIST_GCDRequestType_Beat = 1,                       /* 心跳 */
    NIST_GCDRequestType_GetConversationsList,           /* 获取会话列表 */
    NIST_GCDRequestType_ConnectionAuthAppraisal = 7,    /* 连接鉴权 */
};

/**
 socket 连接状态
 */
typedef NS_ENUM(NSInteger, NIST_GCDSocketConnectStatus)
{
   NIST_GCDSocketConnectStatusDisconnected = -1,        /* 未连接 */
   NIST_GCDSocketConnectStatusConnecting = 0,           /* 连接中 */
   NIST_GCDSocketConnectStatusConnected = 1             /* 已连接 */
};

typedef void (^SocketDidReadBlock)(NSError *__nullable error, id __nullable data);

@protocol NIST_GCDSocketDelegate <NSObject>

@optional
/**
 监听到服务器发送过来的消息

 @param data 数据
 @param type 类型 目前就三种情况（receive messge / kick out / default / ConnectionAuthAppraisal）
 */
- (void)socketReadedData:(nullable id)data
                 forType:(NSInteger)type;

/**
 连上时
 */
- (void)socketDidConnect;

/**
 建连时检测到token失效(检测设备是否是一个同一个设备)

 @param error 错误信息
 */
- (void)connectionAuthAppraisalFailedWithErorr:(nonnull NSError *)error;

@end

@interface NIST_GCDAsyncSocketCommunicationManager : NSObject
@property (nonatomic, assign, readonly) NIST_GCDSocketConnectStatus connectStatus;                  /* 连接状态 */
@property (nonatomic, strong, nonnull) NSString                   * currentCommunicationChannel;    /* 当前请求通道 */
@property (nonatomic, weak, nullable)    id<NIST_GCDSocketDelegate> socketDelegate;                 /* socket 回调 */
@property (nonatomic, assign, readwrite) BOOL                       timeout;                        /* 服务器响应是否超时 */

/**
 获取单例

 @return NIST_GCDAsyncSocketCommunicationManager
 */
+ (nullable NIST_GCDAsyncSocketCommunicationManager *)sharedInstance;

/**
 初始化 socket

 @param config NIST_GCDConnectConfig
 */
- (void)createSocketWithConfig:(nonnull NIST_GCDConnectConfig *)config;

/**
 初始化 socket

 @param token token
 @param channel 连接通道
 */
- (void)createSocketWithToken:(nonnull NSString *)token
                      channel:(nonnull NSString *)channel;

/**
 socket断开连接
 */
- (void)disconnectSocket;

/**
 向服务器发送数据(无序)

 @param type 请求类型
 @param appCode 请求服务代码
 @param body 请求体
 @param callback 数据回调
 */
- (void)socketWriteDataWithRequestType:(NIST_GCDRequestType)type
                               appCode:(NSString *_Nullable)appCode
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback;

/**
 向服务器发送数据(有序)
 
 @param type 请求类型
 @param appCode 请求服务代码
 @param body 请求体
 @param bodyKeys 请求体中的keys
 @param callback 数据回调
 */
- (void)socketWriteDataWithRequestType:(NIST_GCDRequestType)type
                               appCode:(NSString *_Nullable)appCode
                           requestBody:(nonnull NSDictionary *)body
                              bodyKeys:(nonnull NSArray *)bodyKeys
                            completion:(nullable SocketDidReadBlock)callback;

@end
