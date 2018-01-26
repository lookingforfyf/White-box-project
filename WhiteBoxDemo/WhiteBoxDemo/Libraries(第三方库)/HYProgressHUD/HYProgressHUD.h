//  Created by Yuan.He on 12-10-10.
//  Email:heyuan110@gmail.com
//  Copyright (c) 2012年 http://www.heyuan110.com. All rights reserved.

#import <UIKit/UIKit.h>

@interface HYProgressHUD : UIView
{
  UIActivityIndicatorView * rdActivityView;
  UILabel                 * rdMessage;
  UIImageView             * rdCompleteImage;
}

@property (nonatomic, copy)   NSString       * text;
@property (nonatomic, assign) CGFloat          fontSize;
@property (nonatomic, assign) NSTimeInterval   doneVisibleDuration;
@property (nonatomic, assign) BOOL             removeFromSuperviewWhenHidden;

- (void)showInView:(UIView *)view;
- (void)done;
- (void)done:(BOOL)succeeded;
- (void)slash;
- (void)hide;

+ (HYProgressHUD *)sharedProgressHUD;

@end
