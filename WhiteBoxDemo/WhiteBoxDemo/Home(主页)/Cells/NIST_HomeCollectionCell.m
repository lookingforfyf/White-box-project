//
//  NIST_HomeCollectionCell.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_HomeCollectionCell.h"

@implementation NIST_HomeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUI];
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setUI
{
    UILabel * titleLab = [[UILabel alloc]init];
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [titleLab sizeToFit];
    [self.contentView addSubview:titleLab];
    self.titleLab = titleLab;
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(80);
    }];
}

@end
