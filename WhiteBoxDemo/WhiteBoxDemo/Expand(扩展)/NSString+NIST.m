//
//  NSString+NIST.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NSString+NIST.h"

@implementation NSString (NIST)

/* 根据字符串的字体和size(此处size设置为字符串宽和MAXFLOAT)返回多行显示时的字符串size */
- (CGSize)stringSizeWithFont:(UIFont *)font Size:(CGSize)size
{
    
    CGSize resultSize;
    /* 段落样式 */
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    
    /* 字体大小，换行模式 */
    NSDictionary *attributes = @{NSFontAttributeName : font , NSParagraphStyleAttributeName : style};
    resultSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return resultSize;
}

@end
