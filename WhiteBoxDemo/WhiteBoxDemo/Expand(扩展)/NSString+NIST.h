//
//  NSString+NIST.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.根据字符的大小和长度控件自适应
 ***********************************************/
#import <Foundation/Foundation.h>

@interface NSString (NIST)
- (CGSize)stringSizeWithFont:(UIFont *)font
                        Size:(CGSize)size;

@end
