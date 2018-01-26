//
//  NIST_CheckView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/*****************************************
 本类主要负责：
 1.APP启动时，实时呈现检测状态
 *****************************************/
#import <UIKit/UIKit.h>

@interface NIST_CheckView : UIView
@property (nonatomic, strong) UILabel * nameLab;                           /* 检测的功能名称 */
@property (nonatomic, strong) UIImageView * checkImage;                    /* 检测的结果图片 */
@property (nonatomic, strong) UIActivityIndicatorView * indecatorView;     /* 活动指示器 */

@property (nonatomic, copy) NSString * titleStr;
@property (nonatomic, copy) NSString * imageStr;
@property (assign, nonatomic, readwrite) BOOL  isIndecator;

- (instancetype)initWithFrame:(CGRect)frame
                        title:(NSString *)title
                        image:(NSString *)image;

- (instancetype)initWithAndTitle:(NSString *)title
                        andImage:(NSString *)image;

- (instancetype)init;

@end
