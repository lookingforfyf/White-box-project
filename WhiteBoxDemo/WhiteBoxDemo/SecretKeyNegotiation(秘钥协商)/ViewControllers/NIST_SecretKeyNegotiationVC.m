//
//  NIST_SecretKeyNegotiationVC.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2018/1/5.
//  Copyright © 2018年 范云飞. All rights reserved.
//

#import "NIST_SecretKeyNegotiationVC.h"

@interface NIST_SecretKeyNegotiationVC ()
{
    dispatch_queue_t  serialQueue ;
}
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */
@property (copy, nonatomic) NSString * applyKeyAgreementData;                   /* 秘钥协商申请返回数据 */
@property (copy, nonatomic) NSString * keyAgreementRequestData;                 /* 秘钥协商数据返回 */
@property (copy, nonatomic) NSString * keyAgreementResponseData;                /* 秘钥协商认证返回 */
@end

@implementation NIST_SecretKeyNegotiationVC

#pragma mark - life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"业务秘钥协商";
    serialQueue = dispatch_queue_create("com.serialQueue.com", DISPATCH_QUEUE_SERIAL);
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)setUI
{
    UIButton * applykeyBtn = [[UIButton alloc]init];
    applykeyBtn.backgroundColor = [UIColor blackColor];
    applykeyBtn.tag = 3005;
    [applykeyBtn setTitle:@"秘钥协商申请" forState:UIControlStateNormal];
    [applykeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [applykeyBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:applykeyBtn];
    
    [applykeyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    UIButton * requestBtn = [[UIButton alloc]init];
    requestBtn.backgroundColor = [UIColor blackColor];
    requestBtn.tag = 3006;
    [requestBtn setTitle:@"秘钥协商数据" forState:UIControlStateNormal];
    [requestBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestBtn];
    
    [requestBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(applykeyBtn.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    UIButton * responseBtn = [[UIButton alloc]init];
    responseBtn.backgroundColor = [UIColor blackColor];
    responseBtn.tag = 3007;
    [responseBtn setTitle:@"秘钥协商认证" forState:UIControlStateNormal];
    [responseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [responseBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:responseBtn];
    
    [responseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(requestBtn.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    UIButton * confirmBtn = [[UIButton alloc]init];
    confirmBtn.backgroundColor = [UIColor blackColor];
    confirmBtn.tag = 3008;
    [confirmBtn setTitle:@"秘钥协商确认" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(responseBtn.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    
    UIButton * businessBtn = [[UIButton alloc]init];
    businessBtn.backgroundColor = [UIColor blackColor];
    businessBtn.tag = 3009;
    [businessBtn setTitle:@"模拟业务" forState:UIControlStateNormal];
    [businessBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [businessBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:businessBtn];
    
    [businessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(confirmBtn.mas_bottom).offset(30);
        make.left.mas_equalTo((SCREEN_WIDTH - 150)/2);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
}

#pragma mark - Action
- (void)click:(UIButton *)sender
{
#pragma mark - 秘钥协商申请
    if (sender.tag == 3005)
    {
        /* 设置PIN码 */
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]setSecPin:1 pin:user_pwd success:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
        }];
        if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            [Tool showHUD:[NSString stringWithFormat:@"错误信息：%@\n错误码：%@",[dic objectForKey:@"Msg"],[dic objectForKey:@"ErrorCode"]] done:NO];
            return;
        }
        
        /* 秘钥协商申请 */
        NSString * request;
        [[NIST_WB_SDK shareInstance]applykeyAgreement:self.username bussType:@"zhuanzhang" success:^(NSDictionary *data) {
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
        
        [Tool showHUD:@"秘钥协商申请中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"USER_ID":self.username,
                                      @"BUSS_TYPE":@"zhuanzhang",
                                      @"REQ_DATA":request ? request : @""
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0007" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"秘钥协商申请成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.applyKeyAgreementData = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 秘钥协商数据请求
    if (sender.tag == 3006)
    {
        /* 秘钥协商数据 */
        if (self.applyKeyAgreementData == nil || self.applyKeyAgreementData.length == 0)
        {
            NSLog(@"秘钥协商申请失败");
            return;
        }
        NSString * request;
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]keyAgreementRequestData:self.username bussType:@"zhuanzhang" token:self.applyKeyAgreementData success:^(NSDictionary *data) {
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
        
        [Tool showHUD:@"秘钥协商数据请求中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"USER_ID":self.username,
                                      @"BUSS_TYPE":@"zhuanzhang",
                                      @"REQ_DATA":request ? request : @""
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0008" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"秘钥协商数据请求成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.keyAgreementRequestData = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 秘钥协商认证
    if (sender.tag == 3007)
    {
        /* 秘钥协商数据 */
        if (self.keyAgreementRequestData == nil || self.keyAgreementRequestData.length == 0)
        {
            NSLog(@"秘钥协商数据请求失败");
            return;
        }
        NSString * request;
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]keyAgreementResponseData:self.username bussType:@"zhuanzhang" token:self.keyAgreementRequestData success:^(NSDictionary *data) {
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
        
        [Tool showHUD:@"秘钥协商认证中..." inView:self.view];
        
        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
        {
            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
        }
        
        /* 请求参数 */
        NSDictionary *requestBody = @{
                                      @"USER_ID":self.username,
                                      @"BUSS_TYPE":@"zhuanzhang",
                                      @"REQ_DATA":request ? request : @""
                                      };
        WeakSelf(self)
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"00F8" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
                 [Tool showHUD:@"秘钥协商认证成功" done:YES];
                 NSLog(@"callback data:%@",data);
                 NSError * error;
                 NIST_GCDAsyncSocketResponseModel * responseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithString:data error:&error];
                 NSLog(@"responseModel description:%@",[responseModel description]);
                 self.keyAgreementResponseData = responseModel.NIST_MESSAGE.MSG_BODY.RESP_DATA.text;
             }
         }];
    }
#pragma mark - 秘钥协商确认
    if (sender.tag == 3008)
    {
        dispatch_async(serialQueue, ^{
            /* 安全认证码核验 */
            if (self.keyAgreementResponseData == nil || self.keyAgreementResponseData.length == 0)
            {
                NSLog(@"秘钥协商认证数据出错");
                return ;
            }
            
            [Tool showHUD:@"秘钥协商确认中..." inView:self.view];
            sleep(3);/* 耗时操作 */
            
            __block NSDictionary * dic;
            [[NIST_WB_SDK shareInstance]keyAgreementConfirm:self.username bussType:@"zhuanzhang" token:self.keyAgreementResponseData success:^(NSDictionary *data) {
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
#pragma mark - 模拟业务
    if (sender.tag == 3009)
    {
//        [Tool showHUD:@"转账中..." inView:self.view];
//
//        /* 安全认证码核验 */
//        if (self.transferStr == nil || self.transferStr.length == 0)
//        {
//            NSLog(@"转账数据出错");
//            return;
//        }
//
//        /* SM4加密 */
//        NSString * ciphertxt = [[NSString alloc]init];
//        if (0 != [[NIST_WB_SDK shareInstance]sm4_encrypt:[NIST_Tool hexStringFromString:self.transferStr] cipher:&ciphertxt])
//        {
//            NSLog(@"SM4加密失败");
//            return;
//        }
//
//        /* SM3hash */
//        NSString * hash = [[NSString alloc]init];
//        hash = [NIST_SSL sm3:self.transferStr];
//        if (hash == nil || hash.length == 0)
//        {
//            NSLog(@"SM3hash算法失败");
//            return;
//        }
//
//        NSString * request = [NSString stringWithFormat:@"%@\n%@",hash,ciphertxt];
//
//        /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
//        if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
//        {
//            [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
//        }
//
//        /* 请求参数 */
//        NSDictionary *requestBody = @{
//                                      @"USER_ID":self.username,
//                                      @"BUSSTYPE":@"zhuanzhuang",
//                                      @"REQ_DATA":request ? request : @""
//                                      };
//        WeakSelf(self)
//        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0009" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
//         {
//             StrongSelf(self)
//             /* 回调处理 */
//             if (error.code != 0)
//             {
//                 NSLog(@"error:%@",error);
//                 [Tool showHUD:[NSString stringWithFormat:@"%ld %@",error.code,error.localizedDescription] done:NO];
//             }
//             else
//             {
//                 NSLog(@"callback data:%@",data);
//                 [Tool showHUD:@"转账成功" done:YES];
//                 NIST_HomeViewController * home_VC = [[NIST_HomeViewController alloc]init];
//                 UIViewController * target = nil;
//                 for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
//                     if ([controller isKindOfClass:[home_VC class]]) { //这里判断是否为你想要跳转的页面
//                         target = controller;
//                     }
//                 }
//                 if (target) {
//                     [self.navigationController popToViewController:target animated:YES]; //跳转
//                 }
//             }
//         }];
        
        /* 安全认证码核验 */
        if (self.transferStr == nil || self.transferStr.length == 0)
        {
            NSLog(@"转账数据出错");
            return;
        }

        /* SM4加密 */
        NSString * ciphertxt = [[NSString alloc]init];
        if (0 != [[NIST_WB_SDK shareInstance]sm4_encrypt:[NIST_Tool hexStringFromString:self.transferStr] cipher:&ciphertxt])
        {
            NSLog(@"SM4加密失败");
            return;
        }

        /* SM3hash */
        NSString * hash = [[NSString alloc]init];
        hash = [NIST_SSL sm3:self.transferStr];
        if (hash == nil || hash.length == 0)
        {
            NSLog(@"SM3hash算法失败");
            return;
        }
        
        /* 跳转业务 */
        NSArray * array = @[
                            self.transferStr,
                            hash,
                            ciphertxt
                           ];
        NIST_BusinessViewController * business_VC = [[NIST_BusinessViewController alloc]init];
        business_VC.busArray = array;
        business_VC.userName = self.username;
        [self.navigationController pushViewController:business_VC animated:YES];
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
