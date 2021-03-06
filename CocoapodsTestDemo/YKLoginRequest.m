//
//  YKLoginRequest.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/9/14.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "YKLoginRequest.h"

@implementation YKLoginRequest
{
    NSString *_gameId;
    NSString *_openId;
    NSString *_type;
    NSString *_name;
}

- (instancetype)initWithGameId:(NSString *)gameId
                        openId:(NSString *)openId
                          type:(NSString *)type
                          name:(NSString *)name
{
    if (self = [super init]) {
        _gameId = gameId;
        _openId = openId;
        _type = type;
        _name = name;
    }
    return self;
}

-(NSString*)requestUrl{
    
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKLogin];
}

-(YTKRequestMethod)requestMethod{
    
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeJSON;
}

- (id)requestArgument
{
    NSDictionary *params;
    if ([_type isEqualToString:@"WECHAT"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"wechatId":_openId,
                    @"name":_name };
        
    } else if ([_type isEqualToString:@"FACEBOOK"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"facebookId":_openId,
                    @"name":_name };
    } else if ([_type isEqualToString:@"LINE"])
    {
        params = @{ @"gameId":_gameId,
                    @"type":_type,
                    @"lineId":_openId,
                    @"name":_name };
    }
    
    return params;
}

@end

@implementation YKRequestOrder
{
    NSDictionary *_params;
}

- (instancetype)initWithParams:(NSDictionary *)params
{
    if (self = [super init]) {
        _params = params;
    }
    
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetProductsOrder];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType
{
    return YTKResponseSerializerTypeJSON;
}

- (id)requestArgument {
    return _params;
}


@end

@implementation YKGameIdRequest
{
    NSString *_gameId;
}

- (instancetype)initGameId:(NSString *)gameId
{
    if (self = [super init]) {
        _gameId = gameId;
    }
    return self;
}

-(NSString*)requestUrl {
    
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetProduct];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

-(id)requestArgument {
    NSDictionary *body = @{ @"gameId": _gameId };
    return body;
}

@end

@implementation YKPaypalRequest
{
    NSString *_paypalId;
    NSString *_orderNum;
}

- (instancetype)initWithPaypalId:(NSString *)paypalId
                        orderNum:(NSString *)orderNum
{
    if (self = [super init]) {
        _paypalId = paypalId;
        _orderNum = orderNum;
    }
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKPaypal];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    NSDictionary *params = @{ @"paymentId":_paypalId, @"orderNumber":_orderNum};
    return params;
}

@end

@implementation YKWechatPayRequest
{
    NSString *_orderNumber;
}

- (instancetype)initWithOrderNumber:(NSString *)orderNumber
{
    if (self = [super init]) {
        _orderNumber = orderNumber;
    }
    
    return self;
}

- (NSString*)requestUrl {
    return [NSString stringWithFormat:@"%@%@",kIFBaseUrl,kIFSDKGetPayInfo];
}

-(YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    
    NSDictionary *params = @{@"orderNumber":_orderNumber};
    return params;
}


@end

