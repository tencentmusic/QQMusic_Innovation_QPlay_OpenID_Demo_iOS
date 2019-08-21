//
//  QQMusicOpenSDK.m
//  QQMusicOpenSDK
//
//  Created by travisli(李鞠佑) on 2018/10/18.
//  Copyright © 2018年 腾讯音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QQMusicOpenSDK.h"
#import "QQMusicUtils.h"
#import "RSA.h"

#ifndef BuildVersionCString
#define BuildVersionCString "1.0.0.0"
#endif

static NSString * const QQMusic_Scheme = @"qqmusic://";
static NSString * const QQMusic_Scheme_Domain = @"qqmusic://qq.com/other/openid";

static NSString * const kScheme_Cmd = @"cmd";
static NSString * const kScheme_AppId = @"appId";
static NSString * const kScheme_Nonce = @"nonce";
static NSString * const kScheme_Sign = @"sign";
static NSString * const kScheme_CallbackUrl = @"callbackUrl";
static NSString * const kScheme_EncryptString= @"encryptString";
static NSString * const kScheme_ErrorCode= @"errorCode";
static NSString * const kScheme_ErrorMsg= @"errorMsg";
static NSString * const kScheme_OpenId= @"openId";
static NSString * const kScheme_OpenToken= @"openToken";
static NSString * const kScheme_Ret= @"ret";


static NSString * const QQMusic_PubKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrp4sMcJjY9hb2J3sHWlwIEBrJlw2Cimv+rZAQmR8V3EI+0PUK14pL8OcG7CY79li30IHwYGWwUapADKA01nKgNeq7+rSciMYZv6ByVq+ocxKY8az78HwIppwxKWpQ+ziqYavvfE5+iHIzAc8RvGj9lL6xx1zhoPkdaA0agAyuMQIDAQAB";


NSString* const QQMusicOpenSDKVersion = @BuildVersionCString;


typedef NS_ENUM(NSInteger, QMOpenIDAuthResult) {
    QMOpenIDAuthResult_Success  = 0,        //成功
    QMOpenIDAuthResult_Failed   = -1,       //失败
    QMOpenIDAuthResult_Cancel   = -2,       //取消
};


@interface QQMusicOpenSDK()

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *secretKey;
@property (nonatomic, strong) NSString *callbackUrl;
/**
 QQ音乐OpenSDK回调
 */
@property (nonatomic, weak) id<QQMusicOpenSDKDelegate> delegate;

@end

@implementation QQMusicOpenSDK

+ (instancetype)sharedInstance
{
    static QQMusicOpenSDK* g_dQQMusicOpenSDK;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_dQQMusicOpenSDK = [[QQMusicOpenSDK alloc] init];
    });
    return g_dQQMusicOpenSDK;
}


+ (BOOL)registerAppID:(NSString*)appId SecretKey:(NSString*)secretKey callbackUrl:(NSString*)callbackUrl delegate:(id<QQMusicOpenSDKDelegate>)delegate
{
    if (appId.length==0 || secretKey.length==0)
    {
        NSLog(@"非法参数");
        return NO;
    }
    [QQMusicOpenSDK sharedInstance].appId = appId;
    [QQMusicOpenSDK sharedInstance].secretKey = secretKey;
    [QQMusicOpenSDK sharedInstance].callbackUrl = callbackUrl;
    [QQMusicOpenSDK sharedInstance].delegate = delegate;
    return YES;
}

+ (BOOL)isQQMusicInstalled
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:QQMusic_Scheme]])
    {
        return YES;
    }
    return NO;
}

+ (BOOL)openQQMusicApp
{
    if (![QQMusicOpenSDK isQQMusicInstalled])
    {
        return NO;
    }
    NSDictionary *param = @{
                            kScheme_Cmd:@"open",
                            kScheme_AppId:[QQMusicOpenSDK sharedInstance].appId
                            };
    NSString *json = [QQMusicUtils strWithJsonObject:param];
    NSString *scheme = [NSString stringWithFormat:@"%@?p=%@",QQMusic_Scheme_Domain,[json stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [QQMusicOpenSDK openUrl:scheme];
    return YES;
}

+ (void)openUrl:(NSString*)strUrl
{
    if (@available(iOS 10.0, *))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:^(BOOL success) {
            if (!success)
            {
                NSLog(@"openUrl失败,%@",strUrl);
            }
        }];
    }
    else
    {
        if (NO ==[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]])
        {
            NSLog(@"openUrl失败,%@",strUrl);
        }
    }
}

+ (BOOL)startAuth
{
    if ([QQMusicOpenSDK sharedInstance].appId.length==0
        || [QQMusicOpenSDK sharedInstance].secretKey.length==0
        || ![QQMusicOpenSDK isQQMusicInstalled]
        || [QQMusicOpenSDK sharedInstance].delegate==NULL)
    {
        return NO;
    }
    
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    NSString *nonce = [NSString stringWithFormat:@"%.3f",time];
    //1.签名
    NSString *sign = [RSA signString:nonce privateKey:[QQMusicOpenSDK sharedInstance].secretKey];

    NSDictionary *signDict = @{
                               kScheme_Nonce:nonce,
                               kScheme_Sign:sign,
                               kScheme_CallbackUrl:[QQMusicOpenSDK sharedInstance].callbackUrl
                               };
    NSString *sourceString =  [QQMusicUtils strWithJsonObject:signDict];
    //2.加密
    NSString *encryptString = [RSA encryptString:sourceString publicKey:QQMusic_PubKey];
    
    NSDictionary *param = @{
                            kScheme_Cmd:@"auth",
                            kScheme_AppId:[QQMusicOpenSDK sharedInstance].appId,
                            kScheme_EncryptString:encryptString,
                            kScheme_CallbackUrl:[QQMusicOpenSDK sharedInstance].callbackUrl
                            };
    NSString *json = [QQMusicUtils strWithJsonObject:param];
    NSString *scheme = [NSString stringWithFormat:@"%@?p=%@",QQMusic_Scheme_Domain,[json stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [QQMusicOpenSDK openUrl:scheme];
    return YES;
}

+ (NSString*)getQQMusicInstallUrl
{
    return @"https://itunes.apple.com/cn/app/qq-yin-le-2018ge-shou5-meng/id414603431?mt=8";
}


+ (BOOL)handleOpenURL:(NSURL *)url
{
    NSString *json = [[QQMusicUtils queryComponent:url Named:@"p"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (json.length==0)
    {
        return NO;
    }
    NSDictionary *dict = [QQMusicUtils objectWithJsonData:[json dataUsingEncoding:NSUTF8StringEncoding] error:nil targetClass:[NSDictionary class]];
    QMOpenIDAuthResult authResult = (QMOpenIDAuthResult)[[dict objectForKey:kScheme_Ret] integerValue];
    NSString *encryptString = [dict objectForKey:kScheme_EncryptString];
    NSString *decryptString = nil;
    BOOL authPass = NO;
    if (authResult == QMOpenIDAuthResult_Cancel)
    {
        if ([[QQMusicOpenSDK sharedInstance].delegate respondsToSelector:@selector(onAuthCancel)])
        {
            [[QQMusicOpenSDK sharedInstance].delegate onAuthCancel];
        }
        return YES;
    }
    else if (authResult==QMOpenIDAuthResult_Success && encryptString.length>0)
    {
        decryptString = [RSA decryptString:encryptString privateKey:[QQMusicOpenSDK sharedInstance].secretKey];
        NSDictionary *decryptDict = [QQMusicUtils objectWithJsonData:[decryptString dataUsingEncoding:NSUTF8StringEncoding] error:nil targetClass:[NSDictionary class]];
        NSString *nonce = [decryptDict objectForKey:kScheme_Nonce];
        NSString *sign = [decryptDict objectForKey:kScheme_Sign];
        if (sign.length>0 && nonce.length>0)
        {
            authPass = [RSA verify:nonce signature:sign pubKey:QQMusic_PubKey];
            if (authPass)
            {
                //验证通过
                NSString *openID = [decryptDict objectForKey:kScheme_OpenId];
                NSString *openToken = [decryptDict objectForKey:kScheme_OpenToken];
                NSLog(@"验证通过 OpenID:%@,OpenToken:%@",openID,openToken);
                if ([[QQMusicOpenSDK sharedInstance].delegate respondsToSelector:@selector(onAuthSuccess:Token:)])
                {
                    [[QQMusicOpenSDK sharedInstance].delegate onAuthSuccess:openID Token:openToken];
                }
            }
        }
    }
    
    if (!authPass)
    {
        NSInteger errorCode = 0;
        if ([[dict objectForKey:kScheme_ErrorCode] isKindOfClass:[NSNumber class]])
            errorCode = [[dict objectForKey:kScheme_ErrorCode] integerValue];
        NSString *errorMsg = [dict objectForKey:kScheme_ErrorMsg];
        NSLog(@"验证不通过，%@,%ld",errorMsg,(long)errorCode);
        if ([[QQMusicOpenSDK sharedInstance].delegate respondsToSelector:@selector(onAuthFailed:ErrorMsg:)])
        {
            [[QQMusicOpenSDK sharedInstance].delegate onAuthFailed:errorCode ErrorMsg:errorMsg];
        }
    }
    
    return YES;
}

@end
