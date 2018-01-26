//
//  NIST_LaunchFinishController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_LaunchFinishController.h"

@interface NIST_LaunchFinishController ()
@property (strong, nonatomic) NIST_HeadView * headView;
@property (strong, nonatomic) UIButton      * loginBtn;
@property (strong, nonatomic) UIButton      * registBtn;
@end

@implementation NIST_LaunchFinishController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"自检完成";
    [self setNavigationLeftButtonImage:@"icon_nav_back_white"];
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)setUI
{
    /* 创建头视图 */
    NIST_HeadView * headView = [[NIST_HeadView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:headView];
    
    self.headView = headView;
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(84);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 80));
    }];
    
    /* 登录 */
    UIButton * loginBtn = [[UIButton alloc]init];
    loginBtn.backgroundColor = [UIColor blackColor];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.tag = 1000;
    [self.view addSubview:loginBtn];
    self.loginBtn = loginBtn;
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headView.mas_bottom).offset(80);
        make.left.mas_equalTo((SCREEN_WIDTH - 80)/2);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    /* 注册 */
    UIButton * registBtn = [[UIButton alloc]init];
    registBtn.backgroundColor = [UIColor blackColor];
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    registBtn.tag = 1001;
    [self.view addSubview:registBtn];
    self.registBtn = registBtn;
    
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginBtn.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 80)/2);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
    if (sender.tag == 1000)
    {
        NIST_LoginController * login_VC = [[NIST_LoginController alloc]init];
        [self.navigationController pushViewController:login_VC animated:YES];
    }
    if (sender.tag == 1001)
    {
        NIST_RegistController * regist_VC = [[NIST_RegistController alloc]init];
        [self.navigationController pushViewController:regist_VC animated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
