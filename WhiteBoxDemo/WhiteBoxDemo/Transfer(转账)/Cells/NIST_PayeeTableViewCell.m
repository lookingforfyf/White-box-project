//
//  NIST_PayeeTableViewCell.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_PayeeTableViewCell.h"

@interface NIST_PayeeTableViewCell ()<UITextFieldDelegate>

@end

@implementation NIST_PayeeTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    UILabel * titleLab = [[UILabel alloc]init];
    titleLab.text = @"";
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLab];
    self.titleLab = titleLab;
    
    UITextField * payeeTextField = [[UITextField alloc]init];
    payeeTextField.delegate = self;
    payeeTextField.enabled = NO;
    payeeTextField.font = [UIFont systemFontOfSize:16];
    payeeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    payeeTextField.returnKeyType = UIReturnKeyDone;
    payeeTextField.borderStyle = UITextBorderStyleRoundedRect;
    payeeTextField.backgroundColor = [UIColor whiteColor];
    payeeTextField.textColor = [UIColor grayColor];
    payeeTextField.textAlignment = NSTextAlignmentLeft;
//    [payeeTextField addTarget:self action:@selector(textfieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.contentView addSubview:payeeTextField];
    self.payeeTextField = payeeTextField;
}

#pragma mark - Setter
- (void)setDict:(NSDictionary *)dict
{
    self.titleLab.text = [dict objectForKey:@"title"];
    self.payeeTextField.text = [dict objectForKey:@"content"];
    [self setFrame];
}

#pragma mark - Frame
- (void)setFrame
{
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(80);
        make.bottom.mas_equalTo(-5);
    }];
    
    [self.payeeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(self.titleLab.mas_right).offset(0);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-5);
    }];
}

#pragma mark - private method
- (void)textfieldTextDidChange:(UITextField *)textField{
    self.payeeCellBlock(textField.text);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
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
