//
//  NIST_PayeeTableViewCell.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/19.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PayeeCellBlock)(NSString * content);/* 回调 */

@interface NIST_PayeeTableViewCell : UITableViewCell
@property (strong, nonatomic) NSDictionary * dict;
@property (strong, nonatomic) UILabel      * titleLab;
@property (strong, nonatomic) UITextField  * payeeTextField;
@property (copy, nonatomic) PayeeCellBlock payeeCellBlock;
@end
