//
//  NIST_OptVerifyController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_OptVerifyController.h"

@interface NIST_OptVerifyController ()<UITextFieldDelegate>
{
    dispatch_queue_t  serialQueue ;
}
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */
@property (copy, nonatomic) NSString * optRequestData;                          /* 用户绑定认证返回数据 */
@end

@implementation NIST_OptVerifyController
#pragma mark - Lift
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"OPT验证";
    serialQueue = dispatch_queue_create("com.serialQueue.cn", DISPATCH_QUEUE_SERIAL);
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
    NIST_HeadView * headView = [[NIST_HeadView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(84);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
    }];
    
    UILabel * optLabel = [[UILabel alloc]init];
    optLabel.backgroundColor = [UIColor grayColor];
    optLabel.text = [NSString stringWithFormat:@"接收到OTP:%@",[self.optArr objectAtIndex:1]];
    optLabel.font = [UIFont systemFontOfSize:16];
    optLabel.numberOfLines = 0;
    [optLabel sizeToFit];
    optLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:optLabel];
    
    [optLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headView.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.width.mas_equalTo(150);;
    }];
    
    UITextField * verTextField = [[UITextField alloc]init];
    verTextField.delegate = self;
    verTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    verTextField.placeholder = @"短信验证码";
    verTextField.returnKeyType = UIReturnKeyDone;
    verTextField.borderStyle = UITextBorderStyleRoundedRect;
    verTextField.backgroundColor = [UIColor whiteColor];
    verTextField.textColor = [UIColor grayColor];
    verTextField.textAlignment = NSTextAlignmentCenter;
    verTextField.enabled = NO;
    
    [self.view addSubview:verTextField];
    [verTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(optLabel.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];

    UIButton * sureBtn = [[UIButton alloc]init];
    sureBtn.backgroundColor = [UIColor blackColor];
    sureBtn.tag = 3000;
    [sureBtn setTitle:@"OPT验证" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
    
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(verTextField.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 130)/2);
        make.size.mas_equalTo(CGSizeMake(130, 30));
    }];
    
    UIButton * verifyBtn = [[UIButton alloc]init];
    verifyBtn.backgroundColor = [UIColor blackColor];
    verifyBtn.tag = 3001;
    [verifyBtn setTitle:@"OPT反向验证" forState:UIControlStateNormal];
    [verifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [verifyBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verifyBtn];
    
    [verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sureBtn.mas_bottom).offset(50);
        make.left.mas_equalTo((SCREEN_WIDTH - 130)/2);
        make.size.mas_equalTo(CGSizeMake(130, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
#pragma mark - OTP验证
    if (sender.tag == 3000)
    {
        /* 用户OTP验证 */
        __block NSDictionary * dic;
        NSString * request;
        [[NIST_WB_SDK shareInstance]optRequestData:[self.optArr objectAtIndex:0] userId:self.User_ID inData:[self.optArr objectAtIndex:1] success:^(NSDictionary *data) {
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
        
        [Tool showHUD:@"OTP核验中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"REQ_DATA":request ? request : @""
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_ConnectionAuthAppraisal appCode:@"0005" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"OTP核验成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.optRequestData = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - OTP反向认证
    if (sender.tag == 3001)
    {
        dispatch_async(serialQueue, ^{
            /* 安全认证码核验 */
            if (self.optRequestData == nil || self.optRequestData.length == 0)
            {
                NSLog(@"用户绑定认证返回数据出错");
                [Tool showHUD:@"用户绑定认证返回数据出错" done:NO];
                return ;
            }
            
            [Tool showHUD:@"OTP反向认证中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]optResponseDataChecked:self.User_ID token:self.optRequestData success:^(NSDictionary *data) {
                dic = data;
            } failure:^(NSDictionary *error) {
                dic = error;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
                {
                    [Tool showHUD:[dic objectForKey:@"Msg"] done:NO];
                }
                else
                {
                    [Tool showHUD:[dic objectForKey:@"Msg"] done:YES];
                    NIST_LoginController * login_VC = [[NIST_LoginController alloc]init];
                    [self.navigationController pushViewController:login_VC animated:YES];
                }
            });
        });
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
