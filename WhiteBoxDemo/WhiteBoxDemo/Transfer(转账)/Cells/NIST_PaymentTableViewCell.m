//
//  NIST_PaymentTableViewCell.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_PaymentTableViewCell.h"

@interface NIST_PaymentTableViewCell ()<UITextFieldDelegate>

@end

@implementation NIST_PaymentTableViewCell
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
- (void)setUI{
    UILabel * titleLab = [[UILabel alloc]init];
    titleLab.text = @"";
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:titleLab];
    self.titleLab = titleLab;
    
    UITextField * paymentTextField = [[UITextField alloc]init];
    paymentTextField = [[UITextField alloc]init];
    paymentTextField.delegate = self;
    paymentTextField.font = [UIFont systemFontOfSize:16];
    paymentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    paymentTextField.returnKeyType = UIReturnKeyDone;
    paymentTextField.borderStyle = UITextBorderStyleRoundedRect;
    paymentTextField.backgroundColor = [UIColor whiteColor];
    paymentTextField.textColor = [UIColor grayColor];
    paymentTextField.textAlignment = NSTextAlignmentLeft;
    [paymentTextField addTarget:self action:@selector(textfieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.contentView addSubview:paymentTextField];
    self.paymentTextField = paymentTextField;
    
}

#pragma mark - Setter
- (void)setTitleStr:(NSString *)titleStr
{
    self.titleLab.text = titleStr;
}

- (void)setContentStr:(NSString *)contentStr
{
    self.paymentTextField.placeholder = contentStr;
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
    
    [self.paymentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(self.titleLab.mas_right).offset(0);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-5);
    }];
}

#pragma mark - private method
- (void)textfieldTextDidChange:(UITextField *)textField{
    self.paymentCellBlock(self.paymentTextField.text);
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
