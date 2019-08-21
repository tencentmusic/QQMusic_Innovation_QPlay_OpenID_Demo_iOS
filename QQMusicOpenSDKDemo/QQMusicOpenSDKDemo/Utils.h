//
//  Utils.h
//  QQMusicOpenSDKDemo
//
//  Created by travisli(李鞠佑) on 2018/10/30.
//  Copyright © 2018年 腾讯音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (NSString *)strWithJsonObject:(id)object;

+(NSString *)MD5Str:(NSString*)srcString;

@end

NS_ASSUME_NONNULL_END
