//
//  Utils.m
//  QQMusicOpenSDKDemo
//
//  Created by travisli(李鞠佑) on 2018/10/30.
//  Copyright © 2018年 腾讯音乐. All rights reserved.
//

#import "Utils.h"
#include <CommonCrypto/CommonDigest.h>

@implementation Utils

+ (NSString *)strWithJsonObject:(id)object
{
    NSError *error = nil;
    
    if ([NSJSONSerialization isValidJSONObject:object])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        
        if (!error)
        {
            NSString *json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }
    }
    
    NSLog(@"-JSONRepresentation failed. Error is: %@", error);
    return nil;
}

+(NSString *)MD5Str:(NSString*)srcString
{
    const char *cStr = [srcString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}

@end
