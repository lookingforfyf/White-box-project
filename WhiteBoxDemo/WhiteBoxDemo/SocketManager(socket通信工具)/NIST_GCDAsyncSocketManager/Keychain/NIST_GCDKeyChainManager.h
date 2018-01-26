//
//  NIST_GCDKeyChainManager.h
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.存储设备的唯一标识
 *****************************************/
#import <Foundation/Foundation.h>

@interface NIST_GCDKeyChainManager : NSObject
@property (nonatomic, copy) NSString * token;    /* 设备唯一标示 */

/**
 单例
 
 @return NIST_GCDKeyChainManager
 */
+ (NIST_GCDKeyChainManager *)sharedInstance;

@end
