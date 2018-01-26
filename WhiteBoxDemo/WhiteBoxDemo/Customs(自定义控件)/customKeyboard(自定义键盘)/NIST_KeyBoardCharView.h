//
//  NIST_KeyBoardCharView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CharViewClickBlock)(int state,int key,NSString *inputText);

/*
 * 为了给键盘添加取消处理，增加的代理方法
 */
@protocol NIST_KeyBoardCharViewDelegate <NSObject>

@optional
- (void)KeyBoardCharViewButtonCancel:(id)sender;

@end

@interface NIST_KeyBoardCharView : UIView

@property (nonatomic, strong) NSArray * lowerDataSource;    /* 小写 */
@property (nonatomic, strong) NSArray * upperDataSource;    /* 大写 */

@property (nonatomic, copy) CharViewClickBlock charViewClickBlock;
@property (nonatomic, weak) id<NIST_KeyBoardCharViewDelegate> delegate;

- (void)switchKeyBoard;

- (id)initWithFrame:(CGRect)frame;

- (void)initLowerKeyBoard;

- (void)initUpperKeyBoard;

@end
