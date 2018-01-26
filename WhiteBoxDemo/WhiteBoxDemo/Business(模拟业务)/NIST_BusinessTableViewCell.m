//
//  NIST_BusinessTableViewCell.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2018/1/22.
//  Copyright © 2018年 范云飞. All rights reserved.
//

#import "NIST_BusinessTableViewCell.h"
@interface NIST_BusinessTableViewCell()
@property (strong, nonatomic) UILabel * contentLab;
@end

@implementation NIST_BusinessTableViewCell
#pragma mark - Life
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUI];
    }
    return self;
}

#pragma mark - UI
- (void)setUI
{
    UILabel * contentLab = [[UILabel alloc]init];
    contentLab.font = [UIFont systemFontOfSize:16];
    contentLab.numberOfLines = 0;
    [self.contentView addSubview:contentLab];
    self.contentLab = contentLab;

    [self.contentLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.bottom.mas_equalTo(-10);
    }];

}

#pragma mark - Setter
- (void)setContentStr:(NSString *)contentStr
{
    self.contentLab.text = contentStr;
}

@end
