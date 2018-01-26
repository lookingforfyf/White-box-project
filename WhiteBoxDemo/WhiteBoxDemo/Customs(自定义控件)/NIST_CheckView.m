//
//  NIST_CheckView.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_CheckView.h"

@interface NIST_CheckView ()

@end

@implementation NIST_CheckView
- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        image:(NSString *)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleStr = [title copy];
        self.imageStr = [image copy];
        [self setUI];
    }
    return self;
}

- (instancetype)initWithAndTitle:(NSString *)title
                        andImage:(NSString *)image
{
    self = [super init];
    if (self)
    {
        self.titleStr = [title copy];
        self.imageStr = [image copy];
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
    UILabel * nameLab = [[UILabel alloc]init];
    nameLab.text = self.titleStr;
    nameLab.font = [UIFont systemFontOfSize:16];
    nameLab.textAlignment = NSTextAlignmentLeft;
    [nameLab sizeToFit];
    [self addSubview:nameLab];
    self.nameLab = nameLab;
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    UIImageView * checkImage = [[UIImageView alloc]init];
    [checkImage setImage:[UIImage imageNamed:self.imageStr]];
    [self addSubview:checkImage];
    self.checkImage = checkImage;
    
    [self.checkImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(25, 30));
    }];
    
    UIActivityIndicatorView * indecatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indecatorView.hidesWhenStopped = YES;
    [indecatorView startAnimating];
    [self addSubview:indecatorView];
    self.indecatorView = indecatorView;
    
    [self.indecatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(25, 30));
    }];
}

- (void)setIsIndecator:(BOOL)isIndecator
{
    if (isIndecator)
    {
        [self.indecatorView stopAnimating];
        [self.indecatorView removeFromSuperview];
    }
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
