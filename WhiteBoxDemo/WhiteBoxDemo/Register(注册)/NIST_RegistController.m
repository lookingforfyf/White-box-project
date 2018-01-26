//
//  NIST_RegistController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_RegistController.h"

@interface NIST_RegistController ()<UITextFieldDelegate>
@property (strong, nonatomic) UITextField           * teleTextField;
@property (strong, nonatomic) UITextField           * nameTextField;
@property (strong, nonatomic) UITextField           * passwordTextField;
@property (strong, nonatomic) UITextField           * verTextField;
@property (strong, nonatomic) UIView                * verView;
@property (strong, nonatomic) UIButton              * registBtn;
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */
@end

@implementation NIST_RegistController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"注册";
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
    
    UITextField * teleTextField = [[UITextField alloc]init];
    teleTextField.delegate = self;
    teleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    teleTextField.text = mobile_phone;
    teleTextField.enabled = NO;
    teleTextField.returnKeyType = UIReturnKeyDone;
    teleTextField.borderStyle = UITextBorderStyleRoundedRect;
    teleTextField.backgroundColor = [UIColor whiteColor];
    teleTextField.textColor = [UIColor grayColor];
    teleTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:teleTextField];
    [teleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headView.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UITextField * nameTextField = [[UITextField alloc]init];
    nameTextField.delegate = self;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.placeholder = @"输入用户名";
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.textColor = [UIColor grayColor];
    nameTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:nameTextField];
    self.nameTextField = nameTextField;
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(teleTextField.mas_bottom).offset(20);
        make.left.mas_equalTo((SCREEN_WIDTH - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UITextField * passwordTextField = [[UITextField alloc]init];
    passwordTextField.delegate = self;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.text = user_pwd;
    passwordTextField.enabled = NO;
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.textColor = [UIColor grayColor];
    passwordTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:passwordTextField];
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameTextField.mas_bottom).offset(20);
        make.left.mas_equalTo((SCREEN_WIDTH - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UITextField * verTextField = [[UITextField alloc]init];
    verTextField.delegate = self;
    verTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    verTextField.placeholder = @"验证码";
    verTextField.enabled = NO;
    verTextField.returnKeyType = UIReturnKeyDone;
    verTextField.borderStyle = UITextBorderStyleRoundedRect;
    verTextField.backgroundColor = [UIColor whiteColor];
    verTextField.textColor = [UIColor grayColor];
    verTextField.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:verTextField];
    [verTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordTextField.mas_bottom).offset(20);
        make.left.mas_equalTo((SCREEN_WIDTH - 200)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    NIST_VerificationCodeView * verificationView = [[NIST_VerificationCodeView alloc]initWithandCharCount:4
                                                                                             andLineCount:0
                                                    ];
    /* 返回验证码 */
    verificationView.changeVerificationCodeBlock = ^(NSString * code){
        NSLog(@"验证码：%@",code);
    };
    [self.view addSubview:verificationView];
    
    [verificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(verTextField.mas_top);
        make.left.mas_equalTo(verTextField.mas_right).offset(20);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    UIButton * registBtn = [[UIButton alloc]init];
    registBtn.backgroundColor = [UIColor blackColor];
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    self.registBtn = registBtn;
    
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-100);
        make.left.mas_equalTo((SCREEN_WIDTH - 100)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
    /* 用户注册绑定 */
    __block NSDictionary * dic;
    NSString * request;
    [[NIST_WB_SDK shareInstance]bandUserLoginDevice:self.nameTextField.text success:^(NSDictionary *data) {
        dic = data;
    } failure:^(NSDictionary *error) {
        dic = error;
    }];
    if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        [Tool showHUD:[dic objectForKey:@"Msg"] done:NO];
        return;
    }
    else
    {
        request = [dic objectForKey:@"Msg"];
    }
    
    [Tool showHUD:@"用户注册申请中..." inView:self.view];
    
    /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
    if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
    {
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
    }
    
    /* 请求参数 */
    NSDictionary *requestBody = @{
                                  @"USER_ID": self.nameTextField.text,
                                  @"USER_PWD":user_pwd,
                                  @"MOBILE":mobile_phone,
                                  @"REQ_DATA":request ? request : @""
                                  };

    WeakSelf(self)
    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_ConnectionAuthAppraisal appCode:@"0004" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
     {
         StrongSelf(self)
         /* 回调处理 */
         if (error.code != 0)
         {
             NSLog(@"error:%@",error);
             [Tool showHUD:[NSString stringWithFormat:@"%ld %@",error.code,error.localizedDescription] done:NO];
         }
         else
         {
             [Tool showHUD:@"用户注册申请成功" done:YES];
             NSLog(@"callback data:%@",data);
             NSError * error;
             NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
             NSLog(@"responseModel description:%@",[responseModel description]);
             NSArray * recvMsg = [responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text componentsSeparatedByString:@"\n"];
             if (recvMsg.count != 2)
             {
                 NSLog(@"返回的otp验证码错误");
                 return;
             }
             NIST_OptVerifyController * otp_VC = [[NIST_OptVerifyController alloc]init];
             otp_VC.optArr = recvMsg;
             otp_VC.User_ID = self.nameTextField.text;
             [self.navigationController pushViewController:otp_VC animated:YES];
         }
     }];
}

#pragma mark - Lazy
- (NIST_GCDConnectConfig *)connectConfig
{
    if (!_connectConfig)
    {
        _connectConfig = [[NIST_GCDConnectConfig alloc] init];
        _connectConfig.channels = DefaultChannel;
        _connectConfig.currentChannel = DefaultChannel;
        _connectConfig.host = DEVELOPMENT_IP_ADDRESS;
        _connectConfig.port = DEVELOPMENT_PORT;
        _connectConfig.socketVersion = 5;
    }
    _connectConfig.token = @"f14c4e6f6c89335ca5909031d1a6efa9";
    
    return _connectConfig;
}

@end
