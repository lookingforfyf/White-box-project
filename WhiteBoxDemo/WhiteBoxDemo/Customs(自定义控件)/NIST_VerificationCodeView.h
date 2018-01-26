//
//  NIST_VerificationCodeView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.产生随机验证码
 ***********************************************/
#import <UIKit/UIKit.h>

typedef void(^ChangeVerificationCodeBlock)(NSString * code);
@interface NIST_VerificationCodeView : UIView
@property (nonatomic, copy) NSArray * charArray;
@property (nonatomic, strong) NSMutableString * charString;
@property (nonatomic, copy) ChangeVerificationCodeBlock changeVerificationCodeBlock;

- (instancetype)initWithFrame:(CGRect)frame
                 andCharCount:(NSInteger)charCount
                 andLineCount:(NSInteger)lineCount;

- (instancetype)initWithandCharCount:(NSInteger)charCount
                        andLineCount:(NSInteger)lineCount;

@end
