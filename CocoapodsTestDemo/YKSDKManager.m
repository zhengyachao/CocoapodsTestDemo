//
//  YKSDKManager.m
//  ZYCTestDemo
//
//  Created by ifreeplay on 2017/8/7.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "WXApi.h"
#import "YKSDKManager.h"
#import "PayPalMobile.h"
#import "YKLoginRequest.h"
#import "YKElicitIPTool.h"
#import "YKRequestNetwork.h"
#import <LineSDK/LineSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface YKSDKManager ()<LineSDKLoginDelegate,WXApiDelegate>
{
    NSString *_gameId;
    NSString *_type;
    NSString *_orderNumber;
    NSString *_createTimeDate;
}

@property (nonatomic, copy) void(^successBlock)(NSDictionary *data);
@property (nonatomic, copy) void(^failureBlock)(NSError *error);

@end
@implementation YKSDKManager

+ (instancetype)shareManager
{
    static YKSDKManager *ykmanager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ykmanager = [[YKSDKManager alloc] init];
    });
    
    return ykmanager;
}

#pragma mark -- FaceBook登录相关
/* 初始化SDK */
- (void)initSDKForApplication:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions appId:(NSString *)appId clientId:(NSString *)clientIds {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : clientIds}];
    [WXApi registerApp:appId enableMTA:NO];
}

+ (void)activateApp {
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [[FBSDKApplicationDelegate sharedInstance] application:application
                                                           openURL:url
                                                 sourceApplication:sourceApplication
                                                        annotation:annotation];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    BOOL result =  [[LineSDKLogin sharedInstance] handleOpenURL:url];
    
    if (!result)
    {
        BOOL resultFb = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                       openURL:url
                                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
        if (!resultFb)
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
        
        return resultFb;
    }
    
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark -- 登录相关
/* 登录Facebook读取用户权限 */
- (void)loginFacebookVC:(UIViewController *)vc
                 GameId:(NSString *)gameId
                   Type:(NSString *)type
                success:(void (^)(NSDictionary *))successBlock
                failure:(void (^)(NSError *))failureBlock
{
    _gameId = gameId;
    _type = type;
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    login.loginBehavior = FBSDKLoginBehaviorNative;
    [login logInWithReadPermissions: @[@"public_profile",@"email",@"user_about_me"]
                 fromViewController:vc
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         NSLog(@"facebook login result.grantedPermissions = %@,error = %@",result.grantedPermissions,error);
         if (error)
         {
             NSLog(@"Process error");
         } else if (result.isCancelled)
         {
             NSLog(@"Cancelled");
         } else
         {
             NSLog(@"Logged in");
             //获取用户id, 昵称
             if ([FBSDKAccessToken currentAccessToken])
             {
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name" parameters:nil];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                  {
                      NSString *userID = result[@"id"];
                      
                      if (!error && [[FBSDKAccessToken currentAccessToken].userID isEqualToString:userID])
                      {
                          NSString *userID = result[@"id"];
                          NSString *userName = result[@"name"];
                          
                          NSLog(@"userId = %@, userName = %@",userID,userName);
                          [self postServiceName:userName Openid:userID];
                      }
                  }];
             }
         }
     }];
}
/* Line登录相关 */
- (void)startLoginToLineGameId:(NSString *)gameId
                          Type:(NSString *)type
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    
    if ([[LineSDKLogin sharedInstance] canLoginWithLineApp])
    {
        [[LineSDKLogin sharedInstance] startLogin];
    } else
    {
        [[LineSDKLogin sharedInstance] startWebLoginWithSafariViewController:YES];
    }
    [LineSDKLogin sharedInstance].delegate = self;
}

/* LineSDKLoginDelegate方法 */
- (void)didLogin:(LineSDKLogin *)login
      credential:(nullable LineSDKCredential *)credential
         profile:(nullable LineSDKProfile *)profile
           error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else {
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        [self postServiceName:displayName Openid:userID];
    }
}

#pragma mark -- 微信登录

/* WXApiDelegate方法
 * 发送一个sendReq后，收到微信的回应
 */
- (void)onResp:(BaseResp *)resp
{
    NSString *strTitle;
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0)
        {
            [self getWechatAccessTokenWithCode:aresp.code];
        }
    }
    
    if ([resp isKindOfClass:[PayResp class]])
    {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode)
        {
            case WXSuccess:
            {
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
                break;
                
            default:
            {
                strMsg = [NSString stringWithFormat:@"支付结果：失败"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode, resp.errStr);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"支付失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
                break;
        }
    }
}

/* 根据微信的name获取用户信息 */
- (void)loginWechatGetUserInfoVc:(UIViewController *)vc
                          GameId:(NSString *)gameId
                            Type:(NSString *)type
                         success:(void (^)(NSDictionary *))successBlock
                         failure:(void (^)(NSError *))failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    _gameId = gameId;
    _type = type;
    
    if ([WXApi isWXAppInstalled])
    {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    } else
    {
        [self setupAlertController:vc];
    }
}

- (void)setupAlertController:(UIViewController *)vc
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [vc presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 网络请求

- (void)getWechatAccessTokenWithCode:(NSString *)code
{
    NSString *url =[NSString stringWithFormat:kWechatGetToken,kWxApp_id,kWxApp_Secret,code];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers error:nil];
                NSString *accessToken = dic[@"access_token"];
                NSString *openId = dic[@"openid"];
                
                [self getWechatUserInfoWithAccessToken:accessToken openId:openId];
            }
        });
    });
}

- (void)getWechatUserInfoWithAccessToken:(NSString *)accessToken openId:(NSString *)openId
{
    NSString *url =[NSString stringWithFormat:kWechatGetUserInfo,accessToken,openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers error:nil];
                NSString *openId = [dic objectForKey:@"openid"];
                NSString *memNickName = [dic objectForKey:@"nickname"];
                
                [self postServiceName:memNickName Openid:openId];
            }
        });
    });
}

- (void)postServiceName:(NSString *)name Openid:(NSString *)openId
{
    YKLoginRequest *login = [[YKLoginRequest alloc] initWithGameId:_gameId openId:openId type:_type name:name];
    [login startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.responseObject);
        self.successBlock(request.responseObject);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@", request.error);
        self.failureBlock(request.error);
    }];
}

/* 获取orderNumber */
- (void)getOrderInfoWithParams:(NSDictionary *)params
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)(NSError *))failureBlock
{
    
    if ( [params objectForKey:@"totalPrice"] == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"商品总价不能为0" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        });
        return;
    }
    
    YKRequestOrder *orderApi = [[YKRequestOrder alloc] initWithParams:params];
    [orderApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *data = request.responseObject;
        successBlock(data);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
        failureBlock(request.error);
    }];
}
/* 发起微信支付 通过orderNumber*/
- (void)lunchWechatPayWithOrderNum:(NSString *)orderNum orderCreateTime:(NSString *)orderCreateTime
{
    YKWechatPayRequest *wechatApi = [[YKWechatPayRequest alloc] initWithOrderNumber:orderNum];
    [wechatApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSDictionary *result = [request.responseObject objectForKey:@"data"];
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [result objectForKey:@"appid"];
        req.partnerId           = [result objectForKey:@"mch_id"];
        req.prepayId            = [result objectForKey:@"prepay_id"];
        req.nonceStr            = [result objectForKey:@"nonce_str"];
        req.timeStamp           = [orderCreateTime intValue];
        req.package             = @"Sign=WXPay";
        
        NSString *newSign = [YKElicitIPTool createMD5SingForPay:req.openID partnerid:req.partnerId  prepayid:req.prepayId package:req.package noncestr:req.nonceStr timestamp:req.timeStamp];
        req.sign                = newSign;
        [WXApi sendReq:req];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"%@",request.error);
    }];
}

/* 发起Paypal支付验证 通过orderNumber和PayPal回调返回的paypalId*/
- (void)verifyPaypalWithPaypalId:(NSString *)paypalId orderNumber:(NSString *)orderNumber
{
    YKPaypalRequest *paypalApi = [[YKPaypalRequest alloc] initWithPaypalId:paypalId orderNum:orderNumber];
    
    [paypalApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.responseObject);
        if ([[request.responseObject objectForKey:@"code"] intValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Paypal支付成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                [alert show];
            });
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        
        NSLog(@"%@",request.error);
    }];
}
@end
