//
//  AppDelegate.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "WXApi.h"
#import "Stripe.h"
#import "AppDelegate.h"
#import "YKSDKManager.h"
#import "LoginViewController.h"
#import "YTKNetwork.h"

@interface AppDelegate ()<WXApiDelegate>
@end
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //给window设置背景颜色（白色）
    self.window.backgroundColor = [UIColor whiteColor];
    //使window显示
    [self.window makeKeyAndVisible];
    //创建一个视图控制器
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:loginVc];
    navVc.navigationBar.translucent = NO;

    //给window指定根视图控制器

    self.window.rootViewController = navVc;
    
    // 初始化SDK
    [[YKSDKManager shareManager] initSDKForApplication:application launchOptions:launchOptions appId:kWxApp_id clientId:kPaypalClientID];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [YKSDKManager activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
/* iOS 9.0之前 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[YKSDKManager shareManager] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
}

//如果发现弹出的登录无法关闭，请将添加下面这个，注释上面那个
//解决方案来源：http://stackoverflow.com/questions/32299271/facebook-sdk-login-never-calls-back-my-application-on-ios-9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    return  [[YKSDKManager shareManager] application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[YKSDKManager shareManager] application:application handleOpenURL:url];
}

@end
