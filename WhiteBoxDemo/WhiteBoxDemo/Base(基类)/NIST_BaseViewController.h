//
//  NIST_BaseViewController.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.UIViewController 基类
 ***********************************************/
#import <UIKit/UIKit.h>

@interface NIST_BaseViewController : UIViewController
#pragma mark -
- (void)setNavigationLeftButtonImage:(NSString * )imageName;

- (void)setNavigationRightButtonImage:(NSString * )imageName;

- (void)setNavigationRightText:(NSString * )text;

- (void)setNavigationBackItem;

- (void)navigationLeftButtonAction;

- (void)navigationRightButtonAction;

#pragma mark -
/**
 禁止屏幕翻转
 */
- (BOOL)shouldAutorotate;

@end
