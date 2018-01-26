//
//  NIST_RebindController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_RebindController.h"

@interface NIST_RebindController ()

@end

@implementation NIST_RebindController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"重新绑定";
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
    NIST_HeadView * headView = [[NIST_HeadView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(84);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
    }];
    
    UILabel * tipLabel = [[UILabel alloc]init];
    tipLabel.backgroundColor = [UIColor grayColor];
    tipLabel.text = @"此设备并非绑定的登录设备，继续登录需进行设备的重新绑定";
    tipLabel.textColor = [UIColor redColor];
    tipLabel.numberOfLines = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipLabel sizeToFit];
    [self.view addSubview:tipLabel];
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headView.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.width.mas_equalTo(150);
    }];
    
    UIButton * rebindBtn = [[UIButton alloc]init];
    rebindBtn.backgroundColor = [UIColor blackColor];
    [rebindBtn setTitle:@"重新绑定" forState:UIControlStateNormal];
    [rebindBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rebindBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    rebindBtn.tag = 1002;
    [self.view addSubview:rebindBtn];
    
    [rebindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(20);
        make.left.mas_equalTo((SCREEN_WIDTH - 100)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    UIButton * backBtn = [[UIButton alloc]init];
    backBtn.backgroundColor = [UIColor blackColor];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag = 1003;
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(rebindBtn.mas_bottom).offset(20);
        make.left.mas_equalTo((SCREEN_WIDTH - 100)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
    if (sender.tag == 1002)
    {
        NIST_OptVerifyController * login_VC = [[NIST_OptVerifyController alloc]init];
        [self.navigationController pushViewController:login_VC animated:YES];
    }
    if (sender.tag == 1003)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
