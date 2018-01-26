//
//  NIST_GCDAsyncSocketManager.m
//  NIST_SocketManager
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_GCDAsyncSocketManager.h"

/* 基于GCD的socket通信框架 */
#import "GCDAsyncSocket.h"

static const NSInteger TIMEOUT =   10;                            /* socket建立连接的超时时间 */
static const NSInteger kBeatLimit = 3;                            /* 发送心跳的最大次数 */

@interface NIST_GCDAsyncSocketManager ()
@property (nonatomic, strong) GCDAsyncSocket * socket;
@property (nonatomic, assign) NSInteger        beatCount;         /* 发送心跳次数，用于重连 */
@property (nonatomic, strong) NSTimer        * beatTimer;         /* 心跳定时器 */
@property (nonatomic, strong) NSTimer        * reconnectTimer;    /* 重连定时器 */
@property (nonatomic, copy) NSString         * host;              /* Socket连接的host地址 */
@property (nonatomic, assign) uint16_t         port;              /* Sokcet连接的port */
@end

@implementation NIST_GCDAsyncSocketManager
+ (NIST_GCDAsyncSocketManager *)sharedInstance
{
    static NIST_GCDAsyncSocketManager * instance = nil;
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
    self.connectStatus = -1;
    return self;
}

#pragma mark - socket actions
- (void)changeHost:(NSString *)host
              port:(NSInteger)port
{
    self.host = host;
    self.port = port;
}

- (void)connectSocketWithDelegate:(id)delegate
{
    if (self.connectStatus != -1)
    {
        NSLog(@"Socket Connect: YES");
        return;
    }
    self.connectStatus = 0;
    self.socket =
    [[GCDAsyncSocket alloc] initWithDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:TIMEOUT error:&error])
    {
        self.connectStatus = -1;
        NSLog(@"connect error: --- %@", error);
    }
}

- (void)socketDidConnectBeginSendBeat:(NSString *)beatBody
{
    self.connectStatus = 1;
    self.reconnectionCount = 0;
    if (!self.beatTimer)
    {
        self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(sendBeat:)
                                                        userInfo:beatBody
                                                         repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.beatTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)socketDidDisconectBeginSendReconnect:(NSString *)reconnectBody
{
    self.connectStatus = -1;
    
    if (self.reconnectionCount >= 0 && self.reconnectionCount <= kBeatLimit)
    {
        NSTimeInterval time = pow(2, self.reconnectionCount);
        if (!self.reconnectTimer)
        {
            self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                                   target:self
                                                                 selector:@selector(reconnection:)
                                                                 userInfo:reconnectBody
                                                                  repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
        }
        self.reconnectionCount++;
    }
    else
    {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
        self.reconnectionCount = 0;
    }
}

- (void)socketWriteData:(NSString *)data
{
    NSData * requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:requestData withTimeout:-1 tag:0];
    [self socketBeginReadData];
}

- (void)socketBeginReadData
{
    /* 超时时间为10秒 */
//    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:1024*10 tag:0];
    [self.socket readDataWithTimeout:10 tag:0];
    
    /* 暂时先不考虑响应超时， -1：无穷大，一直等待 */
//    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)disconnectSocket
{
    self.reconnectionCount = -1;
    [self.socket disconnect];
    
    [self.beatTimer invalidate];
    self.beatTimer = nil;
}

#pragma mark - public method
- (void)resetBeatCount
{
    self.beatCount = 0;
}

#pragma mark - private method
- (void)sendBeat:(NSTimer *)timer
{
    if (self.beatCount >= kBeatLimit)
    {
        [self disconnectSocket];
        return;
    }
    else
    {
        self.beatCount++;
    }
    if (timer != nil)
    {
        [self socketWriteData:timer.userInfo];
    }
}

- (void)reconnection:(NSTimer *)timer
{
    NSError * error = nil;
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:TIMEOUT error:&error])
    {
        self.connectStatus = -1;
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
