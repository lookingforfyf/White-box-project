//
//  NIST_HeadView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIST_HeadView : UIView
@property (nonatomic, strong) UIImageView * logoImage;    /* 公司logo */
@property (nonatomic, strong) UILabel * nameLab;          /* 公司名 */

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)init;

@end
