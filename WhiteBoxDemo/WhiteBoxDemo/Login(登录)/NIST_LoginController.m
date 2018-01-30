//
//  NIST_LoginController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_LoginController.h"

@interface NIST_LoginController ()<UITextFieldDelegate>
{
    dispatch_queue_t  serialQueue ;
}
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */
@property (copy, nonatomic) NSString * loginRequestData;                        /* 登录认证结果 */
@property (strong, nonatomic) UITextField * nameTextField;
@end

@implementation NIST_LoginController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"登录";
    serialQueue = dispatch_queue_create("com.serialQueue.cnn", DISPATCH_QUEUE_SERIAL);
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
    
    UILabel * teleLabel = [[UILabel alloc]init];
    teleLabel.backgroundColor = [UIColor grayColor];
    teleLabel.text = mobile_phone;
    teleLabel.font = [UIFont systemFontOfSize:20];
    teleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:teleLabel];
    
    [teleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headView.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
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
        make.top.mas_equalTo(teleLabel.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
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
        make.top.mas_equalTo(nameTextField.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    UIButton * loginBtn = [[UIButton alloc]init];
    loginBtn.backgroundColor = [UIColor blackColor];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.tag = 3003;
    [self.view addSubview:loginBtn];
    
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordTextField.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 100)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    UIButton * verifyBtn = [[UIButton alloc]init];
    verifyBtn.backgroundColor = [UIColor blackColor];
    [verifyBtn setTitle:@"登录验证" forState:UIControlStateNormal];
    [verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verifyBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    verifyBtn.tag = 3004;
    [self.view addSubview:verifyBtn];
    
    [verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(loginBtn.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 100)/2);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
#pragma mark - 用户登录请求
    if (sender.tag == 3003)
    {
        /* 用户登录 */
        __block NSDictionary * dic;
        NSString * request;
        [[NIST_WB_SDK shareInstance]loginRequestData:self.nameTextField.text success:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
        }];
        if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%@",[dic objectForKey:@"Msg"],[dic objectForKey:@"ErrorCode"]] done:NO];
            return;
        }
        else
        {
            request = [dic objectForKey:@"Msg"];
        }
        
        [Tool showHUD:@"用户登录中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"USER_ID": self.nameTextField.text,
                                      @"USER_PWD":user_pwd,
                                      @"REQ_DATA":request ? request : @""
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0006" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
         {
             StrongSelf(self)
             /* 回调处理 */
             if (error.code != 0)
             {
                 NSLog(@"error:%@",error);
                 [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%ld ",error.localizedDescription,error.code] done:NO];
             }
             else
             {
                 [Tool showHUD:@"用户登录成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 NSArray * recvMsg = [responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text componentsSeparatedByString:@"\n"];
                 if (recvMsg.count != 2)
                 {
                     NSLog(@"用户登录返回数据出错");
                     return;
                 }
                 self.loginRequestData = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 用户登录认证
    if (sender.tag == 3004)
    {
        NSString * nameText = self.nameTextField.text;
        dispatch_async(serialQueue, ^{
            /* 用户登录反向认证 */
            if (self.loginRequestData == nil || self.loginRequestData.length == 0)
            {
                NSLog(@"用户登录返回数据出错");
                [Tool showHUD:@"用户登录返回数据出错" done:NO];
                return ;
            }
            
            [Tool showHUD:@"用户登录反向认证中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]loginResponseDataChecked:nameText token:self.loginRequestData success:^(NSDictionary *data) {
                dic = data;
            } failure:^(NSDictionary *error) {
                dic = error;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
                {
                    [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%@",[dic objectForKey:@"Msg"],[dic objectForKey:@"ErrorCode"]] done:NO];
                }
                else
                {
                    [Tool showHUD:[dic objectForKey:@"Msg"] done:YES];
                    NIST_HomeViewController * home_VC = [[NIST_HomeViewController alloc]init];
                    home_VC.user_name = self.nameTextField.text;
                    [self.navigationController pushViewController:home_VC animated:YES];
                }
            });
        });
    }
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
