//
//  UtilsMacro.h
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/10.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

typedef enum
{
    YKPlatformType_Facebook, // FACEBOOK
    YKPlatformType_Line,     // LINE
    YKPlatformType_Wechat    // WECHAT
} YKPlatformsType;
// 支付状态
typedef enum
{
    YKPayStatusOPEN,// 新建
    YKPayStatusPAYED,// 已支付
    YKPayStatusREFUND,// 已退款
    YKPayStatusCANCELED // 已取消
} YKPayStatus;
// 货币类型
typedef enum
{
    YKUSD,
    YKHKD,
    YKJPY,
    YKGBP,
    YKEUR
} YKCurrencyType;

#define PlatformsType(enum) [@[@"FACEBOOK",@"LINE",@"WECHAT"] objectAtIndex:enum]
#define PayStatus(enum)     [@[@"OPEN",@"PAYED",@"REFUND",@"CANCELED"] objectAtIndex:enum]
#define CurrencyType(enum)  [@[@"USD",@"HKD",@"JPY",@"GBP",@"EUR"] objectAtIndex:enum]

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)


// 微信相关
#define kWxApp_id      @"wx5c8698af4ea9d013"
#define kWxApp_Secret  @"6404466b271ee9732f15da181ed15ad1"
// Paypal沙箱测试ID
#define kPaypalClientID  @"ATdJEC70AgF4ae_jIaK8WiVMzxBiarr-Whf1dJMAWbGm8IVQG57o28GA_5hLKvNFIH9vIoPqG13MLQ8T"

/* 测试域名 */
#define kIFBaseUrl     @"http://192.168.0.106:8080"
/* 根据微信返回的code获取accessToken和openId接口 */
#define kWechatGetToken                       @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code"
/* 根据微信返回的accessToken和openId来获取用户信息接口 */
#define kWechatGetUserInfo                    @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@"
/* 本地的登录接口 */
#define kIFSDKLogin                           @"/auth/login"
/* 本地根据gameId、productId 获取订单的接口 */
#define kIFSDKGetProductsOrder                @"/order"
/* 本地获取支付订单详情信息接口 (这里指微信)*/
#define kIFSDKGetPayInfo                      @"/payment/wechat"
/* 通过gameId来获取商品信息 */
#define kIFSDKGetProduct                      @"/product/findByGameId"
/* 通过gameId来获取商品信息 */
#define kIFSDKPaypal                          @"/payment/paypal"

#endif /* UtilsMacro_h */
