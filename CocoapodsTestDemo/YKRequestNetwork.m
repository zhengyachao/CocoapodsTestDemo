//
//  YKRequestNetwork.m
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/10.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import "YKRequestNetwork.h"

@implementation YKRequestNetwork

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (void)getRequestByServiceUrl:(NSString *)url
                    parameters:(NSDictionary *)dic
                       success:(YKRequestSuccess )success
                       failure:(YKRequestFailed )failure
{
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:url];
    if ([dic allKeys]) {
        [mutableUrl appendString:@"?"];
        for (id key in dic)
        {
            NSString *value = [[dic objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
        }
    }
    NSString *urlEnCode = [[mutableUrl substringToIndex:mutableUrl.length - 1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode]];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil)
        {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *code = responseObject[@"code"];
            
            switch ([code intValue])
            {
                case 0:
                    success(responseObject);
                    break;
                case 10001:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"参数非法" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                        [alert show];
                    });
                }
                default:
                    break;
            }
        }else
        {
            NSLog(@"%@",error);
            failure(error);
        }
    }];
    [dataTask resume];
}

+ (void)postRequestByServiceUrl:(NSString *)url
                     parameters:(NSDictionary *)dic
                        success:(YKRequestSuccess)success
                        failure:(YKRequestFailed)failure
{
    //创建配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //设置请求超时时间：5秒
    configuration.timeoutIntervalForRequest = 5;
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    //设置请求方式：POST
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-Type"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Accept"];
    
    //data的字典形式转化为data
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //设置请求体
    [request setHTTPBody:jsonData];
    
    NSURLSessionDataTask * dataTask =[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil)
        {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *code = responseObject[@"code"];
            
            switch ([code intValue])
            {
                case 0:
                    success(responseObject);
                    break;
                    case 10001:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"参数非法" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
                        [alert show];
                    });
                }
                default:
                    break;
            }
        }else
        {
            NSLog(@"%@",error);
            failure(error);
        }
    }];
    [dataTask resume];
}

@end
