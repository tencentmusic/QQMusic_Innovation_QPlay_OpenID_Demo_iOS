//
//  ViewController.h
//  QQMusicOpenSDKDemo
//
//  Created by travisli(李鞠佑) on 2018/10/18.
//  Copyright © 2018年 腾讯音乐. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *logView;

- (IBAction)onClickStartAuth:(id)sender;

- (IBAction)onClickInstall:(id)sender;
- (IBAction)onClickOpenQQMusic:(id)sender;
- (IBAction)onClickOpenApi:(id)sender;
@end

