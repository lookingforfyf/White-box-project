//
//  NIST_InputView.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_InputView.h"
#define btnHeight 50

@interface NIST_InputView ()<UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, assign) BOOL isRandom;
@property (nonatomic, strong) dispatch_source_t gcdTimer;
@end

@implementation NIST_InputView
#pragma mark - dealloc
- (void)dealloc
{
    /* 销毁定时器 */
    dispatch_cancel(self.gcdTimer);
    self.gcdTimer = nil;
}

#pragma mark - init
- (instancetype)initIsRandom:(BOOL)isRandom mainView:(UIView *)mainView
{
    self = [super initWithFrame:CGRectNull];
    if (self)
    {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, btnHeight * 4);
        self.isRandom = isRandom;
        [self initViews];
        if ([mainView isKindOfClass:[UITextField class]])
        {
            self.textField = (UITextField *)mainView;
            self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
    }
    return self;
}

#pragma mark - 随机数
- (NSMutableArray *)randomizedArrayWithArray:(NSArray *)array
{
    NSMutableArray *results = [[NSMutableArray alloc]initWithArray:array];
    NSInteger i = [results count];
    while(--i > 0)
    {
        int j = rand() % (i+1);
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    return results;
}

#pragma mark - 长按
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        /* 启动定时器 */
        dispatch_resume(self.gcdTimer);
    }
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        /* 暂停定时器 */
        dispatch_suspend(self.gcdTimer);
    }
}

#pragma mark - timer
- (dispatch_source_t)gcdTimer
{
    if (!_gcdTimer)
    {
        /* 获得队列 */
        dispatch_queue_t queue = dispatch_get_main_queue();
        
        /* 创建一个定时器(dispatch_source_t本质还是个OC对象) */
        _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
        
        uint64_t interval = (uint64_t)(0.1 * NSEC_PER_SEC);//周期
        
        dispatch_source_set_timer(_gcdTimer, start, interval, 0);
        
        __weak typeof(self) weakS = self;
        /* 创建一个定时器(dispatch_source_t本质还是个OC对象) */
        dispatch_source_set_event_handler(self.gcdTimer, ^{
            if (weakS.textField.hasText)
            {
                [weakS.textField deleteBackward];
            }
        });
    }
    return _gcdTimer;
}

#pragma mark - UI
- (void)initViews
{
    CGFloat btnW = self.frame.size.width / 3;
    NSArray * arr1 = @[@"删除",@"0",@"确定"];
    for (int i = 0; i < 3; i++)
    {
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(i * btnW, 0, btnW, btnHeight)];
        if (i == 0)
        {
            UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
            longPressGr.minimumPressDuration = .5;
            [btn addGestureRecognizer:longPressGr];
        }
        if (i == 0 || i == 2)
        {
            btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        else
        {
            btn.backgroundColor = [UIColor whiteColor];
        }
        
        [btn setTitle:arr1[i] forState:0];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.masksToBounds = YES;
        [btn setTitleColor:[UIColor blackColor] forState:0];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        btn.layer.borderWidth = 0.5;
        [self addSubview:btn];
        btn.tag = 200 + i;
    }
    
    int n = 0;
    NSArray * ad = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    NSMutableArray * arr2 = [NSMutableArray arrayWithArray:ad];
    if (self.isRandom)
    {
        arr2 = [self randomizedArrayWithArray:arr2];
    }
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(j * btnW, i * btnHeight + btnHeight, btnW, btnHeight)];
            [btn setTitle:arr2[n] forState:0];
            [btn setTitleColor:[UIColor blackColor] forState:0];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.masksToBounds = YES;
            btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            btn.layer.borderWidth = 0.5;
            [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            btn.tag = 300 + i;
            n++;
        }
    }
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    if (btn.tag < 280)
    {
        if (btn.tag == 200)
        {
            /* 删除 */
            if (self.textField.hasText)
            {
                [self.textField deleteBackward];
            }
        }
        if (btn.tag == 201)
        {
            /* 0 */
            [self.textField insertText:@"0"];
        }
        if (btn.tag == 202)
        {
            /* 确定 */
            [self.textField resignFirstResponder];
        }
    }
    else
    {
        [self.textField insertText:btn.titleLabel.text];
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
