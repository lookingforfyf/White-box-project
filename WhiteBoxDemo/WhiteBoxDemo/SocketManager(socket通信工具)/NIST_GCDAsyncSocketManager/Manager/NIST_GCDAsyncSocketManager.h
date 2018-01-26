//
//  NIST_GCDAsyncSocketManager.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.服务器读写数据
 2.断开连接
 3.心跳
 4.重连
 5.GCDAsyncSocket回调设置
 *****************************************/
#import <Foundation/Foundation.h>

@interface NIST_GCDAsyncSocketManager : NSObject
@property (nonatomic, assign, readwrite) NSInteger connectStatus;        /* 连接状态：1已连接，-1未连接，0连接中 */
@property (nonatomic, assign, readwrite) NSInteger reconnectionCount;    /* 建连失败重连次数 */

/**
 获取单例

 @return NIST_GCDAsyncSocketManager
 */
+ (nullable NIST_GCDAsyncSocketManager *)sharedInstance;

/**
  连接 socket

 @param delegate delegate
 */
- (void)connectSocketWithDelegate:(nonnull id)delegate;

/**
 socket 连接成功后发送心跳的操作

 @param beatBody 发送心跳的请求参数
 */
- (void)socketDidConnectBeginSendBeat:(nonnull NSString *)beatBody;

/**
 socket 连接失败后重接的操作

 @param reconnectBody 连接请求参数
 */
- (void)socketDidDisconectBeginSendReconnect:(nonnull NSString *)reconnectBody;

/**
 向服务器发送数据

 @param data 数据
 */
- (void)socketWriteData:(nonnull NSString *)data;

/**
 socket 读取数据
 */
- (void)socketBeginReadData;

/**
 socket 主动断开连接
 */
- (void)disconnectSocket;

/**
 重设心跳次数
 */
- (void)resetBeatCount;

/**
 设置连接的host和port

 @param host ip地址
 @param port port号
 */
- (void)changeHost:(nullable NSString *)host
              port:(NSInteger)port;

@end
