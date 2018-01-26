//
//  NIST_SetPINController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_SetPINController.h"

@interface NIST_SetPINController ()
@property (strong ,nonatomic) NIST_HeadView     * headView;
@property (strong, nonatomic) UILabel           * tipLab;
@property (strong, nonatomic) UILabel           * tipLab1;
@property (strong, nonatomic) NIST_PasswordView * passwordView;
@property (strong, nonatomic) NIST_PasswordView * passwordView1;
@property (copy, nonatomic) NSString * tempPin;                      /* 临时存储PIN码 */
@end

@implementation NIST_SetPINController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置PIN码";
    [self setNavigationLeftButtonImage:@"icon_nav_back_white"];
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UI
- (void)setUI
{
    /* 创建头视图 */
    NIST_HeadView * headView = [[NIST_HeadView alloc]initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, 80)];
    [self.view addSubview:headView];
    
    UILabel * tipLab = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 150)/2, CGRectGetMaxY(headView.frame) + 15, 150, 30)];
    tipLab.textColor = RGB(255, 165, 0);
    tipLab.text = @"设置安全模块PIN码";
    tipLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLab];
    
    NIST_PasswordView * passwordView = [[NIST_PasswordView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(tipLab.frame) + 15, SCREEN_WIDTH - 60, 40)
                                                                           num:6
                                                                     lineColor:[UIColor blackColor]
                                                                      textFont:30
                                        ];
    
    passwordView.nist_passwordViewType = NIST_PasswordViewSecret;
    passwordView.emptyEditEnd = NO;
    WeakSelf(self)
    passwordView.EndEditBlock = ^(NSString *text) {
        NSLog(@"PIN码：%@",text);
        StrongSelf(self)
        self.tempPin = [text copy];
    };
    [self.view addSubview:passwordView];
    
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLab.mas_bottom).offset(15);
        make.left.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 60, 40));
    }];
    
    UILabel * tipLab1 = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 150)/2, CGRectGetMaxY(passwordView.frame) + 15, 150, 30)];
    tipLab1.textColor = RGB(255, 165, 0);
    tipLab1.text = @"再次输入PIN码";
    tipLab1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLab1];
    
    NIST_PasswordView * passwordView1 = [[NIST_PasswordView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(tipLab1.frame) + 15, SCREEN_WIDTH - 60, 40)
                                                                            num:6
                                                                      lineColor:[UIColor blackColor]
                                                                       textFont:30
                                         ];

    passwordView1.nist_passwordViewType = NIST_PasswordViewSecret;
    passwordView1.emptyEditEnd = NO;
    passwordView1.EndEditBlock = ^(NSString *text) {
        StrongSelf(self)
        if (![self.tempPin isEqualToString:text]) {
            [Tool showHUD:@"两次输入的PIN码不一致" done:NO];
            return ;
        }
        if (self.setpinBlock)
        {
            self.setpinBlock(text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:passwordView1];
}

@end
