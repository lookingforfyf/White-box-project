//
//  NIST_UUID.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/10/31.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.本地算法产生一个唯一标示（用来代替设备唯一标识）
 ***********************************************/
#import <Foundation/Foundation.h>

@interface NIST_UUID : NSObject
#pragma mark -
/**
 获取并保存UUID
 
 @return UUID
 */
+ (NSString *)obtainUUID;

#pragma mark -
/**
 删除UUID
 */
- (void)deleteUUID;
@end
