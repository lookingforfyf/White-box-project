//
//  NIST_PasswordView.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_PasswordView.h"

#define Space 5                                                             /* 间隔 */
#define LineWidth (self.frame.size.width - lineNum * 2 * Space)/lineNum     /* 线的宽度 */
#define LineHeight 2                                                        /* 线的高度 */
#define LineBottomHeight 5                                                  /* 下标线距离底部高度 */
#define RASIUS 5                                                            /* 密码风格远点半径 */

@interface NIST_PasswordView ()<UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray <id>* textArray;
@property (nonatomic, assign, readwrite) NSInteger lineNum;    /* 线的条数 */
@property (nonatomic, strong) UIColor * lineColor;
@property (nonatomic, strong) UIColor * textColor;
@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, strong) NSObject * observer;             /* 观察者 */
@property (nonatomic, strong) UITextField * textField;
@end

@implementation NIST_PasswordView
- (instancetype)initWithFrame:(CGRect)frame
                          num:(NSInteger)num
                    lineColor:(UIColor *)lColor
                     textFont:(CGFloat)font
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        self.textArray = [NSMutableArray arrayWithCapacity:num];
        self.lineNum = num;
        
        /* 数字样式是的颜色和线条颜色相同 */
        self.lineColor = self.textColor = lColor;
        [self addSpaceLine];
        self.layer.borderWidth = 1;
        self.layer.borderColor = lColor.CGColor;
        self.textFont = [UIFont systemFontOfSize:font];

        /* 设置的字体高度小于self的高 */
        NSAssert(self.textFont.lineHeight < self.frame.size.height, @"设置的字体高度应该小于self的高");
        
        /* 单击手势 */
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEdit)];
        [self addGestureRecognizer:tapGes];
    }
    return self;
}

- (instancetype)initWithnum:(NSInteger)num
                  lineColor:(UIColor *)lColor
                   textFont:(CGFloat)font
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.textArray = [NSMutableArray arrayWithCapacity:num];
        self.lineNum = num;
        
        /* 数字样式是的颜色和线条颜色相同 */
        self.lineColor = self.textColor = lColor;
        [self addSpaceLine];
        self.layer.borderWidth = 1;
        self.layer.borderColor = lColor.CGColor;
        self.textFont = [UIFont boldSystemFontOfSize:font];
        
        /* 设置的字体高度小于self的高 */
        NSAssert(self.textFont.lineHeight < self.frame.size.height, @"设置的字体高度应该小于self的高");
        
        /* 单击手势 */
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEdit)];
        [self addGestureRecognizer:tapGes];
    }
    return self;
}

#pragma mark - 添加通知
- (void)addNotification
{
    /* 修复双击造成的bug */
    if (self.observer)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    }
    
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSInteger length = self.textField.text.length;
        
        //改变数组，存储需要画的字符
        //通过判断textfield的长度和数组中的长度比较，选择删除还是添加
        if (length > self.textArray.count)
        {
            [self.textArray addObject:[self.textField.text substringWithRange:NSMakeRange(self.textArray.count, 1)]];
        }
        else
        {
            [self.textArray removeLastObject];
        }
        
        /* 标记为需要重绘 */
        [self setNeedsDisplay];
        if (length == self.lineNum && self.EndEditBlock)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.EndEditBlock(_textField.text);
                [self emptyAndDisplay];
            });
        }
        if (length > self.lineNum)
        {
            _textField.text = [_textField.text substringToIndex:self.lineNum];
            [self emptyAndDisplay];
        }
    }];
}

/* 置空 重绘 */
- (void)emptyAndDisplay
{
    [self endEdit];
    if (self.emptyEditEnd)
    {
        self.textField.text = @"";
        [self.textArray removeAllObjects];
        [self setNeedsDisplay];
    }
}

/* 键盘弹出 */
- (void)beginEdit
{
    if (_textField == nil)
    {
        _textField = [[UITextField alloc] init];
        _textField.inputView = [[NIST_InputView alloc]initIsRandom:NO mainView:_textField];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.hidden = YES;
        _textField.delegate = self;
        [self addSubview:_textField];
    }
    [self addNotification];
    [self.textField becomeFirstResponder];
}

- (void)endEdit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    [self.textField resignFirstResponder];
}

#pragma mark - textfield
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self endEdit];
}

/* 添加分割线 */
- (void)addSpaceLine
{
    for (NSInteger i = 0; i < self.lineNum - 1; i ++)
    {
        CAShapeLayer *line = [CAShapeLayer layer];
        line.fillColor = self.lineColor.CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(self.frame.size.width/self.lineNum * (i + 1), 1, .5, self.frame.size.height - 1)];
        line.path = path.CGPath;
        line.hidden = NO;
        [self.layer addSublayer:line];
    }
}

- (void)drawRect:(CGRect)rect
{
    switch (_nist_passwordViewType)
    {
        case NIST_PasswordViewCustom:
        {
            //画字
            //字的起点
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            for (NSInteger i = 0; i < self.textArray.count; i ++)
            {
                NSString * num = self.textArray[i];
                CGFloat wordWidth = [num stringSizeWithFont:self.textFont Size:CGSizeMake(MAXFLOAT, self.textFont.lineHeight)].width;
                /* 起点 */
                CGFloat startX = self.frame.size.width/self.lineNum * i + (self.frame.size.width/self.lineNum - wordWidth)/2;
                
                [num drawInRect:CGRectMake(startX, (self.frame.size.height - self.textFont.lineHeight - LineBottomHeight - LineHeight)/2, wordWidth,  self.textFont.lineHeight + 5) withAttributes:@{NSFontAttributeName:self.textFont,NSForegroundColorAttributeName:self.textColor}];
            }
            CGContextDrawPath(context, kCGPathFill);
        }
            break;
        case NIST_PasswordViewSecret:
        {
            /* 画圆 */
            CGContextRef context = UIGraphicsGetCurrentContext();
            for (NSInteger i = 0; i < self.textArray.count; i ++)
            {
                /* 圆点 */
                CGFloat pointX = self.frame.size.width/self.lineNum/2 * (2 * i + 1);
                CGFloat pointY = self.frame.size.height/2;
                CGContextAddArc(context, pointX, pointY, RASIUS, 0, 2*M_PI, 0);/* 添加一个圆 */
                CGContextDrawPath(context, kCGPathFill);/* 绘制填充 */
            }
            CGContextDrawPath(context, kCGPathFill);
        }
            break;
        default:
            break;
    }
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
