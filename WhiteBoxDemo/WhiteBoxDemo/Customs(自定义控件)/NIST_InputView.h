//
//  NIST_InputView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.自定义数字键盘
 ***********************************************/
#import <UIKit/UIKit.h>

@interface NIST_InputView : UIView
/**
 返回自定义数字键盘
 
 @param isRandom 是否随机
 @param mainView textField
 @return 自定义键盘
 */
- (instancetype)initIsRandom:(BOOL)isRandom
                    mainView:(UIView *)mainView;

@end
