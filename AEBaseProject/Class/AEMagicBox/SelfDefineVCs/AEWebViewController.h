//
//  AEWebViewController.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AEBaseViewController.h"

@class AEWebViewController;

@protocol AEWebViewControllerDelegate <NSObject>

- (void)webViewControllerDidStartLoad:(AEWebViewController *)controller;

- (void)webViewController:(AEWebViewController *)webController willPushToController:(UIViewController *)pushController animated:(BOOL)animated;

@end

@interface AEWebViewController : AEBaseViewController

@property (strong, nonatomic, readonly) UIWebView *webView;
@property (assign, nonatomic) BOOL backToLink;
@property (copy, nonatomic) NSString *webUrlString;
@property (nonatomic, assign) id<AEWebViewControllerDelegate> delegate;
@property (nonatomic, readonly, strong) NSString *currentUrlString;
@property (nonatomic, assign) BOOL isRootVC;
@property (nonatomic, assign) BOOL hideShare;

/*
 关闭web页面
 */
- (void)closeWebPage;

@end
