//
//  NIST_GCDConnectConfig.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.socket通信，相关参数的配置
 *****************************************/
#import <Foundation/Foundation.h>

@interface NIST_GCDConnectConfig : NSObject
@property (nonatomic, copy) NSString * token;             /* socket配置 */
@property (nonatomic, copy) NSString * channels;          /* 建连时的通道 */
@property (nonatomic, copy) NSString * currentChannel;    /* 当前使用的通道 */
@property (nonatomic, copy) NSString * host;              /* 通信地址 */
@property (nonatomic, assign) uint16_t   port;            /* 通信端口号 */
@property (nonatomic, assign) NSInteger socketVersion;    /* 通信协议版本号 */
@end
