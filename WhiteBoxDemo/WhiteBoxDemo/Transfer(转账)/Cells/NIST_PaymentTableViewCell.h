//
//  NIST_PaymentTableViewCell.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PaymentCellBlock)(NSString * content);/* 回调 */

@interface NIST_PaymentTableViewCell : UITableViewCell
@property (copy, nonatomic) NSString         * titleStr;
@property (copy, nonatomic) NSString         * contentStr;
@property (strong, nonatomic) UILabel        * titleLab;
@property (strong, nonatomic) UITextField    * paymentTextField;
@property (copy, nonatomic) PaymentCellBlock paymentCellBlock;
@end
