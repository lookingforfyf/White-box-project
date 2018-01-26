//
//  NIST_TransferController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/18.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_TransferController.h"

#define split    @"+"
NSString * const KPaymentTableViewCell = @"NIST_PaymentTableViewCell";
NSString * const KPayeeTableViewCell   = @"NIST_PayeeTableViewCell";

@interface NIST_TransferController ()<UITableViewDelegate, UITableViewDataSource>
@property (copy, nonatomic) NSString * pinStr;                                    /* PIN码 */
@property (copy, nonatomic) NSString * amountStr;                                 /* 金额 */
@property (copy, nonatomic) NSString * cardNumberStr;                             /* 卡号 */
@property (copy, nonatomic) NSString * nameStr;                                   /* 收款人姓名 */
@property (copy, nonatomic) NSString * bankStr;                                   /* 银行 */
@property (strong, nonatomic) UITableView * transferTableView;
@property (strong, nonatomic) NSArray < NSDictionary *>* paymentArray;            /* 付款方数据 */
@property (strong, nonatomic) NSArray < NSDictionary *>* payeeArray;              /* 收款方数据 */
@property (copy, nonatomic) NSMutableString * transferStr;                        /* 转账信息 */
@end

@implementation NIST_TransferController
#pragma mark - Life
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"转账";
    [self setNavigationRightText:@"转账"];
    [self setUI];
    [self setData];
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
    [self.view addSubview:self.transferTableView];
    [self.transferTableView registerClass:[NIST_PayeeTableViewCell class] forCellReuseIdentifier:KPayeeTableViewCell];
    [self.transferTableView registerClass:[NIST_PaymentTableViewCell class] forCellReuseIdentifier:KPaymentTableViewCell];
    [self.transferTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - Data
- (void)setData
{
    self.paymentArray = @[
//                         @[
//                           @"付款人",
//                           @"付款行",
//                           @"付款行卡号",
//                           @"付款金额",
//                           @"付款备注"
//                          ],
                         @{
                             @"title":@"付款人",
                             @"content":@"杨红斌"
                             },
                         @{
                             @"title":@"付款行",
                             @"content":@"农行"
                             },
                         @{
                             @"title":@"付款行卡号",
                             @"content":@"6222 4444 5555 6666 789"
                             },
                         @{
                             @"title":@"付款金额",
                             @"content":@"10.00"
                             },
                         @{
                             @"title":@"付款备注",
                             @"content":@"转账业务测试"
                             }
                         ];
    
    self.payeeArray = @[
                        @{
                            @"title":@"收款人",
                            @"content":@"范云飞"
                          },
                        @{
                            @"title":@"收款行",
                            @"content":@"建行"
                          },
                        @{
                            @"title":@"卡号",
                            @"content":@"6222 3333 4444 5555 678"
                            }
                        ];
    NSMutableString * transferStr = [[NSMutableString alloc]init];
    [transferStr appendString:@"范云飞"];
    [transferStr appendString:split];
    [transferStr appendString:@"建行"];
    [transferStr appendString:split];
    [transferStr appendString:@"6222 3333 4444 5555 678"];
    [transferStr appendString:split];
    [transferStr appendString:@"杨红斌"];
    [transferStr appendString:split];
    [transferStr appendString:@"农行"];
    [transferStr appendString:split];
    [transferStr appendString:@"6222 4444 5555 6666 789"];
    [transferStr appendString:split];
    [transferStr appendString:@"10.00"];
    [transferStr appendString:split];
    [transferStr appendString:@"转账业务测试"];
    self.transferStr = [NIST_Tool stringPadding:transferStr cnt:16 padding:@"\n"];
    
    [self.transferTableView reloadData];
}

#pragma mark - UITableViewDelegate&&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.payeeArray.count;
    }
    else
    {
        return self.paymentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0)
//    {
//        NIST_PayeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KPayeeTableViewCell forIndexPath:indexPath];
//        if (!cell)
//        {
//            cell = [[NIST_PayeeTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:KPayeeTableViewCell];
//        }
//
//        cell.dict = self.payeeArray[indexPath.row];
//        return cell;
//    }
//    else
//    {
//        NIST_PaymentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KPaymentTableViewCell forIndexPath:indexPath];
//        if (!cell)
//        {
//            cell = [[NIST_PaymentTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:KPaymentTableViewCell];
//        }
//
//        WeakSelf(self);
//        switch (indexPath.row)
//        {
//            case 0:
//            {
//                cell.paymentCellBlock = ^(NSString *content) {
//                    StrongSelf(self);
//                    self.pinStr = content;
//                };
//            }
//                break;
//            case 1:
//            {
//                cell.paymentCellBlock = ^(NSString *content) {
//                    StrongSelf(self);
//                    self.amountStr = content;
//                };
//            }
//                break;
//            case 2:
//            {
//                cell.paymentCellBlock = ^(NSString *content) {
//                    StrongSelf(self);
//                    self.cardNumberStr = content;
//                };
//            }
//                break;
//            case 3:
//            {
//                cell.paymentCellBlock = ^(NSString *content) {
//                    StrongSelf(self);
//                    self.nameStr = content;
//                };
//            }
//                break;
//            case 4:
//            {
//                cell.paymentCellBlock = ^(NSString *content) {
//                    StrongSelf(self);
//                    self.bankStr = content;
//                };
//            }
//                break;
//            default:
//                break;
//        }
//
//        cell.titleStr = self.paymentArray[indexPath.row];
//        cell.contentStr = self.paymentArray[indexPath.row];
//        return cell;
//    }
    NIST_PayeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KPayeeTableViewCell forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[NIST_PayeeTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:KPayeeTableViewCell];
    }
    if (indexPath.section == 0)
    {
        cell.dict = self.payeeArray[indexPath.row];
    }
    else
    {
        cell.dict = self.paymentArray[indexPath.row];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"收款方信息";
    }
    else
    {
        return @"付款方信息";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - Private
- (void)navigationRightButtonAction
{
    if (self.transferStr == nil || self.transferStr.length == 0)
    {
        UIAlertController * alert_VC = [UIAlertController alertControllerWithTitle:@"转账" message:@"信息有误" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull  action) {
            [self.navigationController dismissViewControllerAnimated:alert_VC completion:nil];
        }];
        
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert_VC addAction:cancelAction];
        
        [alert_VC addAction:sureAction];
        
        [self.navigationController presentViewController:alert_VC animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert_VC = [UIAlertController alertControllerWithTitle:@"转账" message:@"秘钥协商" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NIST_SecretKeyNegotiationVC * secretKey_VC = [[NIST_SecretKeyNegotiationVC alloc]init];
            secretKey_VC.transferStr = self.transferStr;
            secretKey_VC.username = self.User_ID;
            [self.navigationController pushViewController:secretKey_VC animated:YES];
        }];
        
        [alert_VC addAction:sureAction];
        
        [self.navigationController presentViewController:alert_VC animated:YES completion:nil];
    }
}

#pragma mark - Lazy
- (UITableView *)transferTableView
{
    if (!_transferTableView)
    {
        _transferTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _transferTableView.delegate = self;
        _transferTableView.dataSource = self;
        _transferTableView.tableFooterView = [[UIView alloc]init];
    }
    return _transferTableView;
}

@end
