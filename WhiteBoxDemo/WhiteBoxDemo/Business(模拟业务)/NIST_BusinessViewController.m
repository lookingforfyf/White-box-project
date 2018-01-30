//
//  NIST_BusinessViewController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2018/1/22.
//  Copyright © 2018年 范云飞. All rights reserved.
//

#import "NIST_BusinessViewController.h"

NSString * const BusinessTableViewCell   = @"NIST_BusinessTableViewCell";
@interface NIST_BusinessViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NIST_GCDConnectConfig * connectConfig;            /* 配置socket连接 */
@property (strong, nonatomic) UITableView * tableView;
@end

@implementation NIST_BusinessViewController

#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"模拟业务";
    [self setNavigationRightText:@"转账"];
    [self setUI];
    [self setData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)setUI
{
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[NIST_BusinessTableViewCell class] forCellReuseIdentifier:BusinessTableViewCell];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - Data
- (void)setData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate&&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.busArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NIST_BusinessTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:BusinessTableViewCell forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[NIST_BusinessTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BusinessTableViewCell];
    }
    if (indexPath.section == 0)
    {
        cell.contentStr = self.busArray[0];
    }
    else if (indexPath.section == 1)
    {
        cell.contentStr = self.busArray[1];
    }
    else
    {
        cell.contentStr = self.busArray[2];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"转账明文";
    }
    else if (section == 1)
    {
        return @"SM3Hash";
    }
    else
    {
        return @"转账密文";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - Action
- (void)navigationRightButtonAction
{
    if (self.busArray.count < 3)
    {
        NSLog(@"数据错误");
        return;
    }
    
    [Tool showHUD:@"转账中..." inView:self.view];
    
    /* 拼接请求数据 */
    NSString * request = [NSString stringWithFormat:@"%@\n%@",[self.busArray objectAtIndex:1],[self.busArray objectAtIndex:2]];
    
    /* 判断前一次请求是否超时，如果超时socket会自动断开，进行请求操作时 会重新连接*/
    if ([NIST_GCDAsyncSocketCommunicationManager sharedInstance].timeout)
    {
        [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
    }
    
    /* 请求参数 */
    NSDictionary *requestBody = @{
                                  @"USER_ID":self.userName,
                                  @"BUSSTYPE":@"zhuanzhuang",
                                  @"REQ_DATA":request ? request : @""
                                  };
    WeakSelf(self)
    [[NIST_GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:NIST_GCDRequestType_GetConversationsList appCode:@"0009" requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data)
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
             NSLog(@"callback data:%@",data);
             [Tool showHUD:@"转账成功" done:YES];
             sleep(1);
             NIST_HomeViewController * home_VC = [[NIST_HomeViewController alloc]init];
             UIViewController * target = nil;
             for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
                 if ([controller isKindOfClass:[home_VC class]]) { //这里判断是否为你想要跳转的页面
                     target = controller;
                 }
             }
             if (target) {
                 [self.navigationController popToViewController:target animated:YES]; //跳转
             }
         }
     }];
}

#pragma mark - Lazy
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 175;
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

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
