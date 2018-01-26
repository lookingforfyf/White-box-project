//
//  Tool.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/27.
//  Copyright © 2017年 范云飞. All rights reserved.
//

/***********************************************
 本类主要负责：
 1.工具类，主要是toast
 2.获取不同格式的时间戳
 ***********************************************/
#import <Foundation/Foundation.h>

@interface Tool : NSObject
#pragma mark -
+ (Tool * )share;

+ (void)showHUD:(NSString *)msg
           done:(BOOL)done;

+ (void)showHUD:(NSString *)msg
           done:(BOOL)done
         inView:(UIView *)view;

+ (void)showHUD:(NSString *)msg;

+ (void)showHUD:(NSString *)msg
         inView:(UIView *)view;

+ (void)refreshHUDText:(NSString *)msg;

+ (void)refreshHUD:(NSString *)msg
              done:(BOOL)done;

+ (void)hideHUD:(BOOL)done;

+ (void)hideHUD;

#pragma mark -
/**
 获取当前时间(YYYY-MM-dd HH:mm:ss)
 
 @return NSString
 */
+ (NSString *)getYMDHMSTime;

/**
 获取当前日期(YYYY-MM-dd)
 
 @return NSString
 */
+ (NSString *)getYMDTime;

/**
 获取当前时间(HH-m-ss)
 
 @return NSString
 */
+ (NSString *)getHMSTime;

/**
 获取当前时间戳(单位：s)
 
 @return NSString
 */
+ (NSString *)getcurrenttimestampS;

/**
 获取当前时间戳(单位：ms)
 
 @return NSString
 */
+ (NSString *)getcurrenttimestampMS;

@end
