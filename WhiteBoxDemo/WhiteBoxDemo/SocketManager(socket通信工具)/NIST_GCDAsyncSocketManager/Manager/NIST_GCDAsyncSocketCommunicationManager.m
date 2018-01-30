
//  NIST_GCDAsyncSocketCommunicationManager.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIST_GCDAsyncSocketCommunicationManager.h"

/* 基于GCD的socket通信框架 */
#import "GCDAsyncSocket.h"

/* token(设备的唯一标识)保存类 */
#import "NIST_GCDKeyChainManager.h"

/* 负责和socket通信管理 */
#import "NIST_GCDAsyncSocketManager.h"

/* socket请求报文模型 */
#import "NIST_GCDAsyncSocketRequestModel.h"

/* socket响应报文模型 */
#import "NIST_GCDAsyncSocketResponseModel.h"

/* 网络连接的监听 */
#import "AFNetworkReachabilityManager.h"

/* 错误码管理 */
#import "NIST_GCDErrorManager.h"

/* XML和NSDictionary 相互转化工具 */
#import "XMLDictionary.h"

/* XML转NSDictionary */
#import "XMLReader.h"

/* NSDictionary转XML字符串 */
#import "XMLWriter.h"

/* 工具类 */
#import "Tool.h"

/* ip和port配置 */
#import "NIST_GCDSocketConfig.h"

static NSUInteger PROTOCOL_VERSION = 7;                                                      /* 默认通信协议版本号 */

@interface NIST_GCDAsyncSocketCommunicationManager ()<GCDAsyncSocketDelegate>
@property (nonatomic, copy) NSString                         * socketAuthAppraisalChannel;   /* socket验证通道，支持多通道 */
@property (nonatomic, strong) NSMutableDictionary            * requestsMap;                  /* 缓存回调的SocketDidReadBlock 对象 */
@property (nonatomic, strong) NIST_GCDAsyncSocketManager     * socketManager;
@property (nonatomic, assign) NSTimeInterval                   interval;                     /* 服务器与本地时间的差值 */
@property (nonatomic, strong, nonnull) NIST_GCDConnectConfig * connectConfig;                /* socket连接配置 */
@end

@implementation NIST_GCDAsyncSocketCommunicationManager
@dynamic connectStatus;
#pragma mark - init
+ (NIST_GCDAsyncSocketCommunicationManager *)sharedInstance
{
    static NIST_GCDAsyncSocketCommunicationManager * instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.socketManager = [NIST_GCDAsyncSocketManager sharedInstance];
    self.requestsMap = [NSMutableDictionary dictionary];
    [self startMonitoringNetwork];
    return self;
}

#pragma mark - socket actions
- (void)createSocketWithConfig:(nonnull NIST_GCDConnectConfig *)config
{
    if (!config.token.length || !config.channels.length || !config.host.length)
    {
        return;
    }
    self.connectConfig = config;
    self.socketAuthAppraisalChannel = config.channels;
    [NIST_GCDKeyChainManager sharedInstance].token = config.token;
    [self.socketManager changeHost:config.host port:config.port];
    PROTOCOL_VERSION = config.socketVersion;
    
    [self.socketManager connectSocketWithDelegate:self];
}

- (void)createSocketWithToken:(nonnull NSString *)token
                      channel:(nonnull NSString *)channel
{
    if (!token || !channel)
    {
        return;
    }
    
    self.socketAuthAppraisalChannel = channel;
    [NIST_GCDKeyChainManager sharedInstance].token = token;
    [self.socketManager changeHost:@"online socket address" port:7070];
    
    [self.socketManager connectSocketWithDelegate:self];
}

- (void)disconnectSocket
{
    [self.socketManager disconnectSocket];
}

- (void)socketWriteDataWithRequestType:(NIST_GCDRequestType)type
                               appCode:(NSString *_Nullable)appCode
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback;
{
    if (self.socketManager.connectStatus == -1)
    {
        NSLog(@"socket 未连通");
        if (callback)
        {
            callback([NIST_GCDErrorManager errorWithErrorCode:1003],
                     nil);
        }
        return;
    }
    NIST_GCDAsyncSocketRequestModel * socketRequestModel = [[NIST_GCDAsyncSocketRequestModel alloc]init];
    socketRequestModel.MSG_VERSION     = @"1.0";
    socketRequestModel.MSG_TYPE        = @"request";
    socketRequestModel.REQ_SYSTEM      = @"NIST-APP";
//    socketRequestModel.REQ_SYSTEM_CODE = [NSString stringWithFormat:@"APP%@",appCode];
    socketRequestModel.REQ_SYSTEM_CODE = [NSString stringWithFormat:@"I@APP%@",@"001"];
    socketRequestModel.SVR_SYSTEM      = @"NIST-AS";
//    socketRequestModel.SVR_SYSTEM_CODE = [NIST_Device_Info getDeviceModel];
    socketRequestModel.SVR_SYSTEM_CODE = [NSString stringWithFormat:@"C@SVR%@",@"001"];
    socketRequestModel.REQ_DATE        = [Tool getYMDTime];
    socketRequestModel.REQ_TIME        = [Tool getHMSTime];
    socketRequestModel.REQ_DEALNO      = [Tool getcurrenttimestampS];
    socketRequestModel.SVR_CLASS       = @"APP";
    socketRequestModel.SVR_CODE        = appCode;
    socketRequestModel.MSG_BODY        = body;
    socketRequestModel.MAC             = @"报文认证码";
    
    NSString * blockRequestID = [Tool getcurrenttimestampS];/* 请求的时间戳为Key */
    if (callback)
    {
        [self.requestsMap setObject:callback forKey:blockRequestID];/* 缓存回调的block（根据请求的时间戳为Key）*/
    }
    
    /* 第一种NSDictionary 转 XML字符串的方法 */
    NSArray * keys = @[
                       @"MSG_VERSION",
                       @"MSG_TYPE",
                       @"REQ_SYSTEM",
                       @"REQ_SYSTEM_CODE",
                       @"SVR_SYSTEM",
                       @"SVR_SYSTEM_CODE",
                       @"REQ_DATE",
                       @"REQ_TIME",
                       @"REQ_DEALNO",
                       @"SVR_CLASS",
                       @"SVR_CODE",
                       @"MSG_BODY",
                       @"MAC"
                       ];
    NSString * requestBody = [NSDictionary convertDictionaryToXML:[socketRequestModel toDictionary]
                                                             keys:keys
                                                 withStartElement:@"NIST_MESSAGE"
                                                   isFirstElement:YES];
    NSLog(@"writeDataXML:%@",requestBody);
    [self.socketManager socketWriteData:requestBody];
}

- (void)socketWriteDataWithRequestType:(NIST_GCDRequestType)type
                               appCode:(NSString *_Nullable)appCode
                           requestBody:(nonnull NSDictionary *)body
                              bodyKeys:(nonnull NSArray *)bodyKeys
                            completion:(nullable SocketDidReadBlock)callback
{
    if (self.socketManager.connectStatus == -1)
    {
        NSLog(@"socket 未连通");
        if (callback)
        {
            callback([NIST_GCDErrorManager errorWithErrorCode:3],
                     nil);
        }
        return;
    }
    NIST_GCDAsyncSocketRequestModel * socketRequestModel = [[NIST_GCDAsyncSocketRequestModel alloc]init];
    socketRequestModel.MSG_VERSION     = @"1.0";
    socketRequestModel.MSG_TYPE        = @"request";
    socketRequestModel.REQ_SYSTEM      = @"NIST-APP";
    socketRequestModel.REQ_SYSTEM_CODE = [NSString stringWithFormat:@"APP%@",appCode];
    socketRequestModel.SVR_SYSTEM      = @"NIST-AS";
    socketRequestModel.SVR_SYSTEM_CODE = [NIST_Device_Info getDeviceModel];
    socketRequestModel.REQ_DATE        = [Tool getYMDTime];
    socketRequestModel.REQ_TIME        = [Tool getHMSTime];
    socketRequestModel.REQ_DEALNO      = [Tool getcurrenttimestampS];
    socketRequestModel.SVR_CLASS       = @"APP";
    socketRequestModel.SVR_CODE        = appCode;
    socketRequestModel.MSG_BODY        = body;
    socketRequestModel.MAC             = @"报文认证码";
    
    
    NSString * blockRequestID = [Tool getcurrenttimestampS];/* 请求的时间戳为Key */
    if (callback)
    {
        [self.requestsMap setObject:callback forKey:blockRequestID];/* 缓存回调的block（根据请求的时间戳为Key）*/
    }
    
    /* NSDictionary 转 XML字符串的方法 */
    NSArray * keys = @[
                       @"MSG_VERSION",
                       @"MSG_TYPE",
                       @"REQ_SYSTEM",
                       @"REQ_SYSTEM_CODE",
                       @"SVR_SYSTEM",
                       @"SVR_SYSTEM_CODE",
                       @"REQ_DATE",
                       @"REQ_TIME",
                       @"REQ_DEALNO",
                       @"SVR_CLASS",
                       @"SVR_CODE",
                       @"MSG_BODY",
                       @"MAC"
                       ];
    NSString * requestBody = [NSDictionary convertDictionaryToXML:[socketRequestModel toDictionary]
                                                             keys:keys
                                                         bodyKeys:bodyKeys
                                                 withStartElement:@"NIST_MESSAGE"
                                                   isFirstElement:YES];
    NSLog(@"writeDataXML:%@",requestBody);
    [self.socketManager socketWriteData:requestBody];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", socket, host, port);
    [NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout = NO;/* 回调时，置为NO，表示socket处于连接状态 */
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", socket, err);
    NSLog(@"socket 断开连接");
    [Tool showHUD:[NSString stringWithFormat:@"%ld,%@",(long)err.code,err.localizedDescription] done:NO];
    [NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout = YES;/* 回调时，置为YES,表示socket断开连接转改啊 */
    self.socketManager.connectStatus = -1;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (data == nil || data.length == 0)
    {
        return;
    }
    NSLog(@"callback NSData:%@",data);
    NSString * string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"callback string:%@",string);
    NSError * error = nil;
    NSLog(@"callback json:%@",[XMLReader dictionaryForXMLString:string error:&error]);
    NSDictionary * dict = [XMLReader dictionaryForXMLString:string error:&error];
    NSString * jsonString = [XMLReader JSONStringFromDictionary:dict];
    NIST_GCDAsyncSocketResponseModel * socketResponseModel = [[NIST_GCDAsyncSocketResponseModel alloc]initWithDictionary:dict error:&error];
    if (error)
    {
//        [self.socketManager socketBeginReadData];
        NSLog(@"json 解析错误: --- error %@", error);
        return;
    }
    
    NSInteger requestType = 2;/* 根据目前的修先写死 */
    NSInteger errorCode = [socketResponseModel.NIST_MESSAGE.RET_CODE.text integerValue];/* 获取报文的状态码 */
    NSDictionary * resp_time_Dict = [dict objectForKey:@"RESP_TIME"];/* 暂时没用 */
    NSDictionary * body = @{};/* 暂时没用 */
    
    SocketDidReadBlock didReadBlock = self.requestsMap[socketResponseModel.NIST_MESSAGE.REQ_DEALNO.text];/* 从缓存中取出回调的block（根据请求的时间戳为Key）*/
    
    if (errorCode != 0)
    {
        NSError * error = [NIST_GCDErrorManager errorWithErrorCode:errorCode errorMsg:socketResponseModel.NIST_MESSAGE.DESCRIPTION.text];

        if (requestType == NIST_GCDRequestType_ConnectionAuthAppraisal &&
            [self.socketDelegate respondsToSelector:@selector(connectionAuthAppraisalFailedWithErorr:)])
        {
            [self.socketDelegate connectionAuthAppraisalFailedWithErorr:[NIST_GCDErrorManager errorWithErrorCode:1005]];
        }
        if (didReadBlock)
        {
            didReadBlock(error, jsonString);
        }
        return;
    }
    
    switch (requestType)
    {
        case NIST_GCDRequestType_ConnectionAuthAppraisal:
        {
            [self didConnectionAuthAppraisal];
            
            NSDictionary * systemTimeDic = [resp_time_Dict mutableCopy];
            [self differenceOfLocalTimeAndServerTime:[systemTimeDic[@"text"] longLongValue]];
        }
            break;
        case NIST_GCDRequestType_Beat:
        {
            [self.socketManager resetBeatCount];
        }
            break;
        case NIST_GCDRequestType_GetConversationsList:
        {
            NSError * error = [NIST_GCDErrorManager errorWithErrorCode:errorCode errorMsg:socketResponseModel.NIST_MESSAGE.DESCRIPTION.text];
            if (didReadBlock)
            {
                didReadBlock(error, jsonString);
            }
        }
            break;
        default:
        {
            if ([self.socketDelegate respondsToSelector:@selector(socketReadedData:forType:)])
            {
                [self.socketDelegate socketReadedData:body forType:requestType];
            }
        }
            break;
    }
    
//    [self.socketManager socketBeginReadData];
}

#pragma mark - private method
- (NSString *)createRequestID
{
    NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000000;
    NSString * randomRequestID = [NSString stringWithFormat:@"%ld%d", timeInterval, arc4random() % 100000];
    return randomRequestID;
}

- (void)differenceOfLocalTimeAndServerTime:(long long)serverTime
{
    if (serverTime == 0)
    {
        self.interval = 0;
        return;
    }
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    self.interval = serverTime - localTimeInterval;
}

- (long long)simulateServerCreateTime
{
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    localTimeInterval += 3600 * 8;
    localTimeInterval += self.interval;
    return localTimeInterval;
}

- (void)didConnectionAuthAppraisal
{
    if ([self.socketDelegate respondsToSelector:@selector(socketDidConnect)])
    {
        [self.socketDelegate socketDidConnect];
    }

    NIST_GCDAsyncSocketRequestModel * socketRequestModel = [[NIST_GCDAsyncSocketRequestModel alloc]init];
    socketRequestModel.MSG_VERSION     = @"1.0";
    socketRequestModel.MSG_TYPE        = @"request";
    socketRequestModel.REQ_SYSTEM      = @"NIST-APP";
    socketRequestModel.REQ_SYSTEM_CODE = [NSString stringWithFormat:@"APP%@",@"0000"];
    socketRequestModel.SVR_SYSTEM      = @"NIST-AS";
    socketRequestModel.SVR_SYSTEM_CODE = [NIST_Device_Info getDeviceModel];
    socketRequestModel.REQ_DATE        = [Tool getYMDTime];
    socketRequestModel.REQ_TIME        = [Tool getHMSTime];
    socketRequestModel.REQ_DEALNO      = [Tool getcurrenttimestampS];
    socketRequestModel.SVR_CLASS       = @"APP";
    socketRequestModel.SVR_CODE        = @"0000";
    socketRequestModel.MSG_BODY        = @{};
    socketRequestModel.MAC             = @"报文认证码";
    
    /* NSDictionary 转 XML字符串的方法 */
    NSArray * keys = @[
                       @"MSG_VERSION",
                       @"MSG_TYPE",
                       @"REQ_SYSTEM",
                       @"REQ_SYSTEM_CODE",
                       @"SVR_SYSTEM",
                       @"SVR_SYSTEM_CODE",
                       @"REQ_DATE",
                       @"REQ_TIME",
                       @"REQ_DEALNO",
                       @"SVR_CLASS",
                       @"SVR_CODE",
                       @"MSG_BODY",
                       @"MAC"
                       ];
    NSString * requestBody = [NSDictionary convertDictionaryToXML:[socketRequestModel toDictionary]
                                                             keys:keys
                                                 withStartElement:@"NIST_MESSAGE"
                                                   isFirstElement:YES];
    NSLog(@"writeDataXML:%@",requestBody);
    [self.socketManager socketDidConnectBeginSendBeat:requestBody];
}

- (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager * networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status)
         {
             case AFNetworkReachabilityStatusNotReachable:
                 if (weakSelf.socketManager.connectStatus != -1)
                 {
                     [self disconnectSocket];
                 }
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 if (weakSelf.socketManager.connectStatus == -1)
                 {
                     [self createSocketWithToken:[NIST_GCDKeyChainManager sharedInstance].token
                                         channel:self.socketAuthAppraisalChannel];
                 }
                 break;
             default:
                 break;
         }
     }];
}

#pragma mark - getter
- (NIST_GCDSocketConnectStatus)connectStatus
{
    return (NIST_GCDSocketConnectStatus)(self.socketManager.connectStatus);
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
