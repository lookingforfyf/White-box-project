//
//  NIST_KeyBoardSymbolView.h
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/20.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SymbolViewClickBlock)(int state,int key,NSString *inputText);

@interface NIST_KeyBoardSymbolView : UIView

@property (nonatomic, strong) NSArray            * dataSource;   /* 符号 */

@property (nonatomic, copy) SymbolViewClickBlock symbolViewClickBlock;

- (id)initWithFrame:(CGRect)frame;
- (void)initKeyBoard;

@end
