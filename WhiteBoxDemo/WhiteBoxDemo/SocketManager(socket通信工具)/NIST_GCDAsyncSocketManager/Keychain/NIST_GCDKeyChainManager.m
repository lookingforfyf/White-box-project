//
//  NIST_GCDKeyChainManager.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_GCDKeyChainManager.h"

@implementation NIST_GCDKeyChainManager
+ (NIST_GCDKeyChainManager *)sharedInstance
{
    static NIST_GCDKeyChainManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setToken:(NSString *)token
{
    _token = token;
}

@end
