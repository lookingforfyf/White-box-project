//
//  AppDelegate.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]init];
    
    /* 设置导航栏 */
    NSDictionary * navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:24.0f]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:30/255.0f green:144/255.0f blue:255/255.0f alpha:1.0]];
    
    /* 键盘管理 */
    IQKeyboardManager * manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    manager.enableAutoToolbar = NO;
    manager.toolbarManageBehaviour = IQAutoToolbarByTag;
    
    /* rootView */
    NIST_LaunchController * launch_VC = [[NIST_LaunchController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:launch_VC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

/* 进制屏幕翻转 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{

}


- (void)applicationWillTerminate:(UIApplication *)application
{

}


@end
