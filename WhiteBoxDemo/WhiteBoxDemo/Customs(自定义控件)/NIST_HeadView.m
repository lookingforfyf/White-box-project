//
//  NIST_HeadView.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.公司logo和公司名的展示View
 *****************************************/
#import "NIST_HeadView.h"

@implementation NIST_HeadView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    UIImageView * logoImage = [[UIImageView alloc]init];
    [logoImage setImage:[UIImage imageNamed:@"logo"]];
    [self addSubview:logoImage];
    self.logoImage = logoImage;
    
    [self.logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    UILabel * nameLab = [[UILabel alloc]init];
    nameLab.textColor = RGB(34, 144, 255);
    nameLab.text = @"国信安泰";
    nameLab.font = [UIFont systemFontOfSize:30];
    nameLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLab];
    self.nameLab = nameLab;
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImage.mas_top).offset(20);
        make.left.mas_equalTo(self.logoImage.mas_right).offset(30);
        make.right.mas_equalTo(self.mas_right).offset(-30);
        make.height.mas_equalTo(30);
    }];

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
