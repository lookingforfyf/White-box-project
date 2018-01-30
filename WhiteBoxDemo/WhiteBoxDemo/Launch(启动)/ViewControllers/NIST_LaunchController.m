//
//  NIST_LaunchController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_LaunchController.h"

@interface NIST_LaunchController ()
{
    dispatch_queue_t  serialQueue ;
}
@property (strong, nonatomic) NSArray <NSString *>* dataArray;
@property (strong, nonatomic) NIST_HeadView       * headView;
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */

@property (copy, nonatomic) NSString * termidResponse;                          /* 申请终端编号的应答数据 */
@property (copy, nonatomic) NSString * applyAuthenticationToken;                /* 请求双向认证的应答token */
@property (copy, nonatomic) NSString * tokenResponseDataChecked;                /* 反向认证码 */
@end

@implementation NIST_LaunchController
#pragma mark - Lift
- (void)viewWillAppear:(BOOL)animated
{
    /* 配置连接环境 */
    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"国信安泰";
    serialQueue = dispatch_queue_create("com.serialQueue", DISPATCH_QUEUE_SERIAL);
    [self setData];
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
    NIST_HeadView * headView = [[NIST_HeadView alloc]init];
    [self.view addSubview:headView];
    self.headView = headView;
    
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(84);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 80));
    }];
    
    UIButton * inspectionBtn = [[UIButton alloc]init];
    inspectionBtn.tag = 2000;
    [inspectionBtn setTitle:[self setLabelTitle:0] forState:UIControlStateNormal];
    [inspectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [inspectionBtn setBackgroundColor:[UIColor grayColor]];
    [inspectionBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inspectionBtn];
    
    [inspectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headView.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * enumBtn = [[UIButton alloc]init];
    enumBtn.tag = 2001;
    [enumBtn setTitle:[self setLabelTitle:1] forState:UIControlStateNormal];
    [enumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [enumBtn setBackgroundColor:[UIColor grayColor]];
    [enumBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enumBtn];
    
    [enumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inspectionBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * securityModuleBtn = [[UIButton alloc]init];
    securityModuleBtn.tag = 2002;
    [securityModuleBtn setTitle:[self setLabelTitle:2] forState:UIControlStateNormal];
    [securityModuleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [securityModuleBtn setBackgroundColor:[UIColor grayColor]];
    [securityModuleBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:securityModuleBtn];
    
    [securityModuleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(enumBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * numberApplicationBtn = [[UIButton alloc]init];
    numberApplicationBtn.tag = 2003;
    [numberApplicationBtn setTitle:[self setLabelTitle:3] forState:UIControlStateNormal];
    [numberApplicationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [numberApplicationBtn setBackgroundColor:[UIColor grayColor]];
    [numberApplicationBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:numberApplicationBtn];
    
    [numberApplicationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(securityModuleBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * loadingSerialNumberBtn = [[UIButton alloc]init];
    loadingSerialNumberBtn.tag = 2004;
    [loadingSerialNumberBtn setTitle:[self setLabelTitle:4] forState:UIControlStateNormal];
    [loadingSerialNumberBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loadingSerialNumberBtn setBackgroundColor:[UIColor grayColor]];
    [loadingSerialNumberBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loadingSerialNumberBtn];
    
    [loadingSerialNumberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(numberApplicationBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * securityCodeBtn = [[UIButton alloc]init];
    securityCodeBtn.tag = 2005;
    [securityCodeBtn setTitle:[self setLabelTitle:5] forState:UIControlStateNormal];
    [securityCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [securityCodeBtn setBackgroundColor:[UIColor grayColor]];
    [securityCodeBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:securityCodeBtn];
    
    [securityCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(loadingSerialNumberBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * twoWayApplicationBtn = [[UIButton alloc]init];
    twoWayApplicationBtn.tag = 2006;
    [twoWayApplicationBtn setTitle:[self setLabelTitle:6] forState:UIControlStateNormal];
    [twoWayApplicationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [twoWayApplicationBtn setBackgroundColor:[UIColor grayColor]];
    [twoWayApplicationBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twoWayApplicationBtn];
    
    [twoWayApplicationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(securityCodeBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * certificationRequestBtn = [[UIButton alloc]init];
    certificationRequestBtn.tag = 2007;
    [certificationRequestBtn setTitle:[self setLabelTitle:7] forState:UIControlStateNormal];
    [certificationRequestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [certificationRequestBtn setBackgroundColor:[UIColor grayColor]];
    [certificationRequestBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:certificationRequestBtn];
    
    [certificationRequestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(twoWayApplicationBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIButton * reverseCheckBtn = [[UIButton alloc]init];
    reverseCheckBtn.tag = 2008;
    [reverseCheckBtn setTitle:[self setLabelTitle:8] forState:UIControlStateNormal];
    [reverseCheckBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reverseCheckBtn setBackgroundColor:[UIColor grayColor]];
    [reverseCheckBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reverseCheckBtn];
    
    [reverseCheckBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(certificationRequestBtn.mas_bottom).offset(10);
        make.left.mas_equalTo((self.view.frame.size.width - 200)/2);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)button
{
    if (!serialQueue)
    {
        return;
    }
#pragma mark - 安全模块申请
    if (button.tag == 2000)
    {
        [Tool showHUD:@"安全模块申请中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 获取公钥文件请求数据 */
        __block NSDictionary * dic;
        NSString * request;
        [[NIST_WB_SDK shareInstance]applySecModule:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
            [Tool showHUD:[error objectForKey:@"Msg"] done:NO];
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
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"REQ_DATA": request ? request : @"",
                                      };
        
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0000" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
         {
             /* 回调处理 */
             if (error.code != 0)
             {
                 NSLog(@"error:%@",error);
                 [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%ld ",error.localizedDescription,error.code] done:NO];
             }
             else
             {
                 [Tool showHUD:@"安全模块申请成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 [[NIST_WB_SDK shareInstance]installSecModule:responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text success:^(NSDictionary *data) {
                     NSLog(@"data:%@",data);
                 } failure:^(NSDictionary *error) {
                     NSLog(@"error:%@",error);
                 }];
             }
         }];
    }
#pragma mark - 安全模块自检
    if (button.tag == 2001)
    {
        dispatch_async(serialQueue, ^{
            [Tool showHUD:@"自检中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]selfCheckZSec:^(NSDictionary *data) {
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
                }
            });
        });
    }
#pragma mark - 枚举硬件特征信息
    if (button.tag == 2002)
    {
        dispatch_async(serialQueue, ^{
            [Tool showHUD:@"枚举中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
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
                }
            });
        });
    }
#pragma mark - 申请终端编号
    if (button.tag == 2003)
    {
        NIST_SetPINController * setPin_VC = [[NIST_SetPINController alloc]init];
        setPin_VC.setpinBlock = ^(NSString *pin) {
            if (pin == nil || pin.length == 0)
            {
                NSLog(@"PIN出错");
                return ;
            }
            
            /* 设置PIN码 */
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]setSecPin:0 pin:pin success:^(NSDictionary *data) {
                dic = data;
            } failure:^(NSDictionary *error) {
                dic = error;
            }];
            if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
            {
                [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%@",[dic objectForKey:@"Msg"],[dic objectForKey:@"ErrorCode"]] done:NO];
                return;
            }
            
            /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
            if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
            {
                [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
            }
            
            /* 枚举设备特征信息 */
            NSString * deviceFeatures;
            [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
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
                deviceFeatures = [dic objectForKey:@"Msg"];
            }
            
            /* 获取公钥文件请求数据 */
            NSString * request;
            [[NIST_WB_SDK shareInstance]createTermIdRequestData:deviceFeatures success:^(NSDictionary *data) {
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

            [Tool showHUD:@"申请终端编号..." inView:self.view];
            /* 请求参数 */
            NSDictionary *requestBody = @{
                                          @"REQ_DATA": request ? request : @"",
                                          };
            
            WeakSelf(self)
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0001" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                     [Tool showHUD:@"终端编号申请成功" done:YES];
                     NSLog(@"callback data:%@",data);
                     NSError * error;
                     NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                     self.termidResponse = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
                 }
             }];
        };
        [self.navigationController pushViewController:setPin_VC animated:YES];
    }
#pragma mark - 终端编号装载
    if (button.tag == 2004)
    {
        dispatch_async(serialQueue, ^{
            /* 枚举硬件特征值 */
            __block NSDictionary * dic;
            NSString * deviceFeatures;
            [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
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
                deviceFeatures = [dic objectForKey:@"Msg"];
            }
            
            [Tool showHUD:@"终端编号装载中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            /* 装载终端编号 */
            [[NIST_WB_SDK shareInstance]setupTermId:deviceFeatures termIdData:self.termidResponse success:^(NSDictionary *data) {
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
                }
            });
        });
    }
#pragma mark - 安全认证码核验
    if (button.tag == 2005)
    {
        dispatch_async(serialQueue, ^{
            [Tool showHUD:@"安全认证码核验中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            /* 安全认证码核验 */
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]checkZcode:^(NSDictionary *data) {
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
                }
            });
        });
    }
#pragma mark - 双向认证申请
    if (button.tag == 2006)
    {
        [Tool showHUD:@"双向认证申请中..." inView:self.view];
        
        /* 获取请求双向认证数据 */
        __block NSDictionary * dic;
        NSString * request;
        [[NIST_WB_SDK shareInstance]applyAuthentication:^(NSDictionary *data) {
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
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"REQ_DATA": request ? request : @"",
                                      };
        
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0002" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"请求双向认证成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.applyAuthenticationToken = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 发起挑战码认证请求
    if (button.tag == 2007)
    {
        /* 发起挑战码认证请求 */
        NSString * request;
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]tokenRequestData:self.applyAuthenticationToken success:^(NSDictionary *data) {
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
        
        [Tool showHUD:@"挑战码认证请求中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"REQ_DATA": request ? request : @"",
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0003" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"挑战码认证请求成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.tokenResponseDataChecked = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 挑战码反向认证
    if (button.tag == 2008)
    {
        dispatch_async(serialQueue, ^{
            /* 安全认证码核验 */
            if (self.tokenResponseDataChecked == nil || self.tokenResponseDataChecked.length == 0)
            {
                NSLog(@"挑战码认证请求返回数据错误");
                [Tool showHUD:@"挑战码认证请求返回数据错误" done:NO];
                return;
            }
            
            [Tool showHUD:@"挑战码反向认证中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            /* 挑战码反向认证 */
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]tokenResponseDataChecked:self.tokenResponseDataChecked success:^(NSDictionary *data) {
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
                    NIST_LaunchFinishController * launchFinish_VC = [[NIST_LaunchFinishController alloc]init];
                    [self.navigationController pushViewController:launchFinish_VC animated:YES];
                }
            });
        });
    }
}

#pragma mark - Data
- (void)setData
{
    self.dataArray = @[
                       @"1.安全模块申请",
                       @"2.安全模块自检",
                       @"3.硬件特征枚举",
                       @"4.终端编号申请",
                       @"5.终端编号装载",
                       @"6.安全认证码核验",
                       @"7.双向认证申请",
                       @"8.发起认证请求",
                       @"9.反向认证核验"
                       ];
}

- (NSString *)setLabelTitle:(NSInteger)index
{
    return [self.dataArray objectAtIndex:index];
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
