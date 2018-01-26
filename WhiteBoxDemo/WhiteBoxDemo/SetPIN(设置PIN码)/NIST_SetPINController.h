//
//  NIST_SetPINController.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_BaseViewController.h"

typedef void (^setPinBlock)(NSString * pin);
@interface NIST_SetPINController : NIST_BaseViewController
@property (nonatomic, copy) setPinBlock setpinBlock;
@end
