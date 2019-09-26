//
//  ViewController.m
//  QQMusicOpenSDKDemo
//
//  Created by travisli(李鞠佑) on 2018/10/18.
//  Copyright © 2018年 腾讯音乐. All rights reserved.
//

#import "ViewController.h"
#import "QQMusicOpenSDK.h"
#import "Utils.h"


static NSString * const OPENID_APP_PRIVATEKEY = @"";
static NSString * const OPENID_APPID = @"";
static NSString * const OPENID_PACKAGENAME = @"";

static NSString * const OPENAPI_APPID = @"";
static NSString * const OPENAPI_APPKEY = @"";
static NSString * const OPENAPI_APPPRIVATEKEY = @"";

@interface ViewController ()<QQMusicOpenSDKDelegate>

@property (nonatomic,strong) NSString *openId;
@property (nonatomic,strong) NSString *openToken;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BOOL installed = [QQMusicOpenSDK isQQMusicInstalled];
    NSString *msg = [NSString stringWithFormat:@"OpenID授权Demo\nQQ音乐:%@\nSDK版本:%@",installed?@"已安装":@"未安装",QQMusicOpenSDKVersion];
    self.logView.text =msg;
    [QQMusicOpenSDK registerAppID:OPENID_APPID packageName:OPENID_PACKAGENAME SecretKey:OPENID_APP_PRIVATEKEY callbackUrl:@"qm123456://" delegate:self];
}


- (IBAction)onClickStartAuth:(id)sender {
    [QQMusicOpenSDK startAuth];
}

- (IBAction)onClickInstall:(id)sender {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[QQMusicOpenSDK getQQMusicInstallUrl]] options:@{} completionHandler:NULL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[QQMusicOpenSDK getQQMusicInstallUrl]]];
    }
}

- (IBAction)onClickOpenQQMusic:(id)sender {
     [QQMusicOpenSDK openQQMusicApp];
}

- (IBAction)onClickOpenApi:(id)sender {
    if (self.openId.length==0 || self.openToken.length==0)
    {
        UIAlertController * alert1 = [UIAlertController alertControllerWithTitle:nil message:@"请先授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert1 addAction:exitAction];
        [self presentViewController:alert1 animated:YES completion:nil];
        [self.logView setText:@"请先授权"];
        return;
    }
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"OpenAPI请求" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* searchAction = [UIAlertAction actionWithTitle:@"搜索"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction* action)
                                   
                                   {
                                       [self requestSearch];
                                       [alertView dismissViewControllerAnimated: YES completion: nil];
                                   }];
    UIAlertAction* mvAction = [UIAlertAction actionWithTitle:@"MV分类"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
                             
                             {
                                 [self requestMVTag];
                                 [alertView dismissViewControllerAnimated: YES completion: nil];
                             }];
    UIAlertAction* singerAction = [UIAlertAction actionWithTitle:@"歌手专辑列表"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action)
                               
                               {
                                   [self requestSingerAlbums];
                                   [alertView dismissViewControllerAnimated: YES completion: nil];
                               }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction* action)
                               
                               {
                                   [alertView dismissViewControllerAnimated: YES completion: nil];
                               }];
    
    
    [alertView addAction:searchAction];
    [alertView addAction:mvAction];
    [alertView addAction:singerAction];
    [alertView addAction:cancelAction];
    [self presentViewController:alertView animated:NO completion:nil];
}

- (void)onAuthFailed:(NSInteger)errorCode ErrorMsg:(NSString *)errorMsg {
    NSString *msgText = [NSString stringWithFormat:@"授权失败\nErrorCode:%ld\nErrorMsg:%@",(long)errorCode,errorMsg];
    UIAlertController * alert1 = [UIAlertController alertControllerWithTitle:nil message:msgText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert1 addAction:exitAction];
    [self presentViewController:alert1 animated:YES completion:nil];
}

- (void)onAuthSuccess:(NSString *)openID Token:(NSString *)openToken {
    NSString *msgText = [NSString stringWithFormat:@"授权成功\nOpenID:%@\nOpenToken:%@",openID,openToken];
    self.openId = openID;
    self.openToken = openToken;
    
    UIAlertController * alert1 = [UIAlertController alertControllerWithTitle:nil message:msgText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert1 addAction:exitAction];
    [self presentViewController:alert1 animated:YES completion:nil];
}

- (void)onAuthCancel
{
    UIAlertController * alert1 = [UIAlertController alertControllerWithTitle:nil message:@"用户取消授权" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert1 addAction:exitAction];
    [self presentViewController:alert1 animated:YES completion:nil];
}

- (void)traceLog:(NSString *)log level:(QQMusicLogLevel)level {
    [self.logView setText:log];
}

- (NSString*)getSign:(long)unixTime
{
    NSString *srcString = [NSString stringWithFormat:@"OpitrtqeGzopIlwxs_%@_%@_%@_%ld",OPENAPI_APPID,OPENAPI_APPKEY,OPENAPI_APPPRIVATEKEY,unixTime];
    NSString *sign = [Utils MD5Str:srcString];
    return sign;
}

- (void)requestSearch
{
    NSString *keyword = @"周杰伦";
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long unixTime = (long)time;
    NSString *sign = [self getSign:unixTime];
    NSString *encodeKeyword = [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"http://openrpc.music.qq.com/rpc_proxy/fcgi-bin/music_open_api.fcg?opi_cmd=fcg_music_custom_search.fcg&app_id=%@&app_key=%@&timestamp=%ld&sign=%@&login_type=6&qqmusic_open_appid=%@&qqmusic_open_id=%@&qqmusic_access_token=%@&t=0&w=%@",OPENAPI_APPID,OPENAPI_APPKEY,unixTime,sign,OPENID_APPID,self.openId,self.openToken,encodeKeyword];
    [self requestUrl:url name:@"搜索"];
}

- (void)requestMVTag
{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long unixTime = (long)time;
    NSString *sign = [self getSign:unixTime];
    NSString *url = [NSString stringWithFormat:@"http://openrpc.music.qq.com/rpc_proxy/fcgi-bin/music_open_api.fcg?opi_cmd=fcg_music_custom_get_mv_by_tag.fcg&app_id=%@&app_key=%@&timestamp=%ld&sign=%@&login_type=6&mv_area=0&mv_year=0&mv_type=2&mv_tag=10&mv_pageno=1&mv_pagecount=2&mv_cmd=gettaglist&qqmusic_open_appid=%@&qqmusic_open_id=%@&qqmusic_access_token=%@",OPENAPI_APPID,OPENAPI_APPKEY,unixTime,sign,OPENID_APPID,self.openId,self.openToken];
     [self requestUrl:url name:@"MV分类"];
}

- (void)requestSingerAlbums
{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    long unixTime = (long)time;
    NSString *sign = [self getSign:unixTime];
    NSString *url = [NSString stringWithFormat:@"http://openrpc.music.qq.com/rpc_proxy/fcgi-bin/music_open_api.fcg?opi_cmd=fcg_music_custom_get_singer_album.fcg&app_id=%@&app_key=%@&timestamp=%ld&sign=%@&login_type=6&singer_id=87&page_index=0&num_per_page=10&order=0&qqmusic_open_appid=%@&qqmusic_open_id=%@&qqmusic_access_token=%@",OPENAPI_APPID,OPENAPI_APPKEY,unixTime,sign,OPENID_APPID,self.openId,self.openToken];
    [self requestUrl:url name:@"歌手专辑列表"];
}

- (void)requestUrl:(NSString *)url name:(NSString*)name
{
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"从服务器获取到数据");
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                NSString *str = [Utils strWithJsonObject:dict];
                [self.logView setText:[NSString stringWithFormat:@"请求%@成功\n%@",name,str]];
            }
            else
            {
                [self.logView setText:[NSString stringWithFormat:@"请求%@失败",name]];
            }
        });
    }];
    [sessionDataTask resume];
}


@end
