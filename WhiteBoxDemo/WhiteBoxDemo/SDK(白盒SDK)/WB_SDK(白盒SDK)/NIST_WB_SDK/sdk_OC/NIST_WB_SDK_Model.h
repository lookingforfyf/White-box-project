//
//  NIST_WB_SDK_Model.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/11/3.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.记录SDK中操作的状态
 2.0 表示成功
 3.非0表示失败
 ***********************************************/
#import <Foundation/Foundation.h>

@interface NIST_WB_SDK_Model : NSObject
@property (assign, nonatomic, readwrite) NSInteger selfCheck;                  /* 记录SDK自检状态 */
@property (assign, nonatomic, readwrite) NSInteger probeDeviceFeatures;        /* 记录硬件枚举特征信息状态 */
@property (assign, nonatomic, readwrite) NSInteger checkTermId;                /* 记录终端编号核验状态 */
@property (assign, nonatomic, readwrite) NSInteger createTermIdRequestData;    /* 记录终端编号申请数据状态 */
@property (assign, nonatomic, readwrite) NSInteger setupTermId;                /* 记录终端编号装载状态 */
@property (assign, nonatomic, readwrite) NSInteger checkZcode;                 /* 记录安全认证码核验状态 */
@end
