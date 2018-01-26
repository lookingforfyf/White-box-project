//
//  NIST_PassWordKeyBoardView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KeyBoardLayoutStyle)
{
    KeyBoardLayoutStyleDefault=-1,       /* 默认字母 */
    KeyBoardLayoutStyleNumbers=0,        /* 数字 */
    KeyBoardLayoutStyleLetters=1,        /* 小写字母 */
    KeyBoardLayoutStyleUperLetters=2,    /* 大写字母 */
    KeyBoardLayoutStyleSymbol            /* 符号 */
};

@interface NIST_PassWordKeyBoardView : UIView

/**
 *  键盘属性
 */
@property (nonatomic, assign) KeyBoardLayoutStyle keyBoardLayoutStyle;

/**
 初始化键盘
 */
- (instancetype)initKeyboardView;

/**
 *	@brief	键盘输入框和界面输入框关联
 *
 *	@param 	relationShipTextFiled 	界面输入框
 */
- (void)setRelationShipTextFiled:(UITextField *)relationShipTextFiled;

@end
