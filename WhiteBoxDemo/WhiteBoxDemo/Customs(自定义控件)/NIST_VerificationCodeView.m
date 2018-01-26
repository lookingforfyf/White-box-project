//
//  NIST_VerificationCodeView.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_VerificationCodeView.h"

@interface NIST_VerificationCodeView ()
@property (nonatomic, assign) NSInteger charCount;    /* 字符串数量 */
@property (nonatomic, assign) NSInteger lineCount;    /* 线条数量 */
@end

@implementation NIST_VerificationCodeView
#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
                 andCharCount:(NSInteger)charCount
                 andLineCount:(NSInteger)lineCount
{
    if (self = [super initWithFrame:frame])
    {
        self.charCount = charCount;
        self.lineCount = lineCount;
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RandomColor;
        [self changeValidationCode];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)]];
    }
    return self;
}

- (instancetype)initWithandCharCount:(NSInteger)charCount
                        andLineCount:(NSInteger)lineCount
{
    self = [super init];
    if (self)
    {
        self.charCount = charCount;
        self.lineCount = lineCount;
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RandomColor;
        [self changeValidationCode];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)]];
    }
    return self;
}

- (void)tapGesture
{
    [self changeValidationCode];
    [self setNeedsDisplay];
}

#pragma mark - 更换验证码
- (void)changeValidationCode
{
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:self.charCount];
    self.charString = [[NSMutableString alloc] initWithCapacity:self.charCount];
    
    for(NSInteger i = 0; i < self.charCount; i++)
    {
        NSInteger index = arc4random() % ([self.charArray count]);
        getStr = [self.charArray objectAtIndex:index];
        self.charString = (NSMutableString *)[self.charString stringByAppendingString:getStr];
    }
    
    if (self.changeVerificationCodeBlock)
    {
        self.changeVerificationCodeBlock(self.charString);
    }
}

#pragma mark - 绘制界面
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.backgroundColor = RandomColor;
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    CGFloat pointX, pointY;
    
    NSString *text = [NSString stringWithFormat:@"%@",self.charString];
    NSInteger charWidth = rectWidth / text.length - 15;
    NSInteger charHeight = rectHeight - 25;
    
    /* 依次绘制文字 */
    for (NSInteger i = 0; i < text.length; i++)
    {
        /* 文字X坐标 */
        pointX = arc4random() % charWidth + rectWidth / text.length * i;
        /* 文字Y坐标 */
        pointY = arc4random() % charHeight;
        unichar charC = [text characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%C", charC];
        
        [textC drawAtPoint:CGPointMake(pointX, pointY) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:arc4random() % 10 + 15]}];
    }
    
    /* 获取上下文 */
    CGContextRef context = UIGraphicsGetCurrentContext();
    /* 设置线宽 */
    CGContextSetLineWidth(context, 1.0);
    
    /* 依次绘制直线 */
    for(NSInteger i = 0; i < self.lineCount; i++)
    {
        /* 设置线的颜色 */
        CGContextSetStrokeColorWithColor(context, RandomColor.CGColor);
        /* 设置线的起点 */
        pointX = arc4random() % (NSInteger)rectWidth;
        pointY = arc4random() % (NSInteger)rectHeight;
        CGContextMoveToPoint(context, pointX, pointY);
        /* 设置线的终点 */
        pointX = arc4random() % (NSInteger)rectWidth;
        pointY = arc4random() % (NSInteger)rectHeight;
        CGContextAddLineToPoint(context, pointX, pointY);
        /* 绘画路径 */
        CGContextStrokePath(context);
    }
}

#pragma mark - Lazy loading
- (NSArray *)charArray
{
    if (!_charArray)
    {
        _charArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
    }
    return _charArray;
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
