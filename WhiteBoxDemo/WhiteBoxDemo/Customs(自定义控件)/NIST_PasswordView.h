//
//  NIST_PasswordView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.设置PIN码时的输入框
 ***********************************************/
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NIST_PasswordViewCustom,/* 普通样式 */
    NIST_PasswordViewSecret,/* 密码样式 */
} NIST_PasswordViewType;

@interface NIST_PasswordView : UIView
@property (nonatomic, copy) void(^EndEditBlock)(NSString * text);             /* 输入完成回调 */
@property (nonatomic, assign) NIST_PasswordViewType nist_passwordViewType;    /* 样式 */
@property (nonatomic, assign) BOOL emptyEditEnd;                              /* 是否需要输入之后清空，再次输入使用 ，默认为NO*/

/**
 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame
                          num:(NSInteger)num
                    lineColor:(UIColor *)lColor
                     textFont:(CGFloat)font;

- (instancetype)initWithnum:(NSInteger)num
                    lineColor:(UIColor *)lColor
                     textFont:(CGFloat)font;

/**
 开始编辑
 */
- (void)beginEdit;

/**
 结束编辑
 */
- (void)endEdit;

@end
