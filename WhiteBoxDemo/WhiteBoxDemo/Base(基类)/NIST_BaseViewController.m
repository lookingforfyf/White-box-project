//
//  NIST_BaseViewController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_BaseViewController.h"

@interface NIST_BaseViewController ()

@end

@implementation NIST_BaseViewController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - base
- (void)setNavigationLeftButtonImage:(NSString * )imageName
{
    UIImage * btnImage = [UIImage imageNamed:imageName];
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
    [leftBtn setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(navigationLeftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)setNavigationRightButtonImage:(NSString * )imageName
{
    UIImage * btnImage = [UIImage imageNamed:imageName];
    UIButton * rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
    [rightBut setBackgroundImage:btnImage forState:UIControlStateNormal];
    [rightBut addTarget:self action:@selector(navigationRightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBut];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setNavigationBackItem
{
    UIImage * btnImage = [UIImage imageNamed:@"item_back"];
    UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
    [leftBtn setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(navigationLeftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)setNavigationRightText:(NSString * )text
{
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:self action:@selector(navigationRightButtonAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)navigationLeftButtonAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationRightButtonAction
{
    
}

#pragma mark - 禁止屏幕翻转
- (BOOL)shouldAutorotate
{
    return NO;
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
