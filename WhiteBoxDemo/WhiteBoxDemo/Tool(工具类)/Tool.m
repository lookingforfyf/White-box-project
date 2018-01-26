//
//  Tool.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/27.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "Tool.h"

static Tool * tool = nil;
@implementation Tool
#pragma mark - toast
+ (Tool *)share
{
    static dispatch_once_t once;
    dispatch_once(&once,^{
        tool = [[Tool alloc] init];
    });
    return tool;
}

+ (void)showHUD:(NSString *)msg
           done:(BOOL)done
         inView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HYProgressHUD sharedProgressHUD] setText:msg];
        if ([HYProgressHUD sharedProgressHUD].isHidden)
        {
            [[HYProgressHUD sharedProgressHUD] showInView:view];
        }
        [[HYProgressHUD sharedProgressHUD] done:done];
    });
}

+ (void)showHUD:(NSString *)msg
           done:(BOOL)done
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Tool showHUD:msg done:done inView:[[UIApplication sharedApplication] keyWindow]];
    });
}

+ (void)showHUD:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HYProgressHUD sharedProgressHUD] setText:msg];
        if ([HYProgressHUD sharedProgressHUD].isHidden)
        {
            [Tool showHUD:msg inView:[[UIApplication sharedApplication] keyWindow]];
        }
    });
}

+ (void)showHUD:(NSString *)msg
         inView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HYProgressHUD sharedProgressHUD] setText:msg];
        if ([HYProgressHUD sharedProgressHUD].isHidden)
        {
            [[HYProgressHUD sharedProgressHUD] showInView:view];
        }
    });
}

+ (void)refreshHUDText:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([HYProgressHUD sharedProgressHUD].isHidden)
        {
            [Tool showHUD:msg];
        }
        [[HYProgressHUD sharedProgressHUD] setText:msg];
        [[HYProgressHUD sharedProgressHUD] slash];
    });
}

+ (void)refreshHUD:(NSString *)msg
              done:(BOOL)done
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([HYProgressHUD sharedProgressHUD].isHidden)
        {
            [Tool showHUD:msg];
        }
        [[HYProgressHUD sharedProgressHUD] setText:msg];
        [[HYProgressHUD sharedProgressHUD] done:done];
    });
}

+ (void)hideHUD
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HYProgressHUD sharedProgressHUD] hide];
    });
}

+ (void)hideHUD:(BOOL)done
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[HYProgressHUD sharedProgressHUD] done:done];
    });
}

#pragma mark - 获取当前时间(YYYY-MM-dd HH:mm:ss)
+ (NSString *)getYMDHMSTime
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    /* 设置时间格式 */
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    /* 设置时区 */
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    /* 获取当前时间 */
    NSDate * date = [NSDate date];
    NSString * timeStamp = [formatter stringFromDate:date];
    return timeStamp;
}

#pragma mark - 获取当前日期(YYYY-MM-dd)
+ (NSString *)getYMDTime
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    /* 设置时间格式 */
    [formatter setDateFormat:@"YYYYMMdd"];
    /* 获取当前时间 */
    NSDate * date = [NSDate date];
    NSString * currenttimeString = [formatter stringFromDate:date];
    return currenttimeString;
}

#pragma mark - 获取当前时间(HH-m-ss)
+ (NSString *)getHMSTime
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    /* 设置时间格式 */
    [formatter setDateFormat:@"HHmmss"];
    /* 获取当前时间 */
    NSDate * date = [NSDate date];
    NSString * currenttimeString = [formatter stringFromDate:date];
    return currenttimeString;
}

#pragma mark - 获取当前时间戳(单位：s)
+ (NSString *)getcurrenttimestampS
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    /* 设置时间格式 */
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    /* 设置时区 */
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    /* 获取当前时间 */
    NSDate * date = [NSDate date];
    NSString * timeStampS = [NSString stringWithFormat:@"%ld",(long)[date timeIntervalSince1970]];
    return timeStampS;
}

#pragma mark - 获取当前时间戳(单位：ms)
+ (NSString *)getcurrenttimestampMS
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    /* 设置时间格式 */
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"];
    /* 设置时区 */
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate * date = [NSDate date];
    NSString * timeStampMS = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]*1000];
    return timeStampMS;
}

#pragma mark - MLeaksFinder（内存泄漏检测工具）
- (BOOL)willDealloc
{
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf assertNotDealloc];
    });
    return YES;
}

- (void)assertNotDealloc
{
    NSAssert(NO, @"内存泄漏");
}

@end
