//
//  YKRequestNetwork.h
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/10.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YKRequestSuccess)(NSDictionary *data);
typedef void (^YKRequestFailed)(NSError *error);

@interface YKRequestNetwork : NSObject

/* get 网络请求 */
+ (void)getRequestByServiceUrl:(NSString *)url
                    parameters:(NSDictionary *)dic
                       success:(YKRequestSuccess )success
                       failure:(YKRequestFailed )failure;

/* post 网络请求 */
+ (void)postRequestByServiceUrl:(NSString *)url
                     parameters:(NSDictionary *)dic
                        success:(YKRequestSuccess)success
                        failure:(YKRequestFailed)failure;

@end
