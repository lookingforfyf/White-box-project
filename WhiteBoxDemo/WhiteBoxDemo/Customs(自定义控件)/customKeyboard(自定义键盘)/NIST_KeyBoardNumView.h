//
//  NIST_KeyBoardNumView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NumViewClickBlock)(int key,NSString *title);

@interface NIST_KeyBoardNumView : UIView

@property (nonatomic, strong) NSArray         * dataSource;
@property (nonatomic, copy) NumViewClickBlock numViewClickBlock;

/* 初始化键盘数字 */
- (void)initNum;

@end
