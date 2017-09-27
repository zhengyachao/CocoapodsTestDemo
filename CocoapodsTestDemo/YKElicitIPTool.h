//
//  YKElicitIPTool.h
//  CocoapodsTestDemo
//
//  Created by ifreeplay on 2017/8/30.
//  Copyright © 2017年 ifreeplay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKElicitIPTool : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (NSString *)createMD5SingForPay:(NSString *)appid_key
                        partnerid:(NSString *)partnerid_key
                         prepayid:(NSString *)prepayid_key
                          package:(NSString *)package_key
                         noncestr:(NSString *)noncestr_key
                        timestamp:(UInt32)timestamp_key;
@end
