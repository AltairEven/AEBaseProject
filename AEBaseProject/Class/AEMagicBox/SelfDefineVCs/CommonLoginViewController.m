//
//  CommonLoginViewController.m
//  PingYu
//
//  Created by Qian Ye on 16/3/29.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "CommonLoginViewController.h"

@interface CommonLoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property (weak, nonatomic) IBOutlet UIView *displayBGView;
@property (weak, nonatomic) IBOutlet UIButton *alipayButton;
@property (weak, nonatomic) IBOutlet UILabel *alipayLabel;
@property (weak, nonatomic) IBOutlet UIButton *weiboButton;
@property (weak, nonatomic) IBOutlet UILabel *weiboLabel;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UILabel *qqLabel;

- (IBAction)didClickedLoginButton:(id)sender;

- (IBAction)didClickedCancelButton:(id)sender;

- (void)resetShareButtonStatus;

@end

@implementation CommonLoginViewController

+ (instancetype)instanceWithLoginSucceed:(void (^)())succeed failure:(void (^)())failure {
    CommonLoginViewController *controller = [[CommonLoginViewController alloc] initWithNibName:@"CommonLoginViewController" bundle:nil];
    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.displayBGView setBackgroundColor:[[KTCThemeManager manager] defaultTheme].globalBGColor];
    [self.tapView setHidden:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedCancelButton:)];
    [self.tapView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetShareButtonStatus];
    [self.view.superview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tapView setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tapView setHidden:YES];
}

#pragma mark Private methods


- (IBAction)didClickedLoginButton:(id)sender {
}

- (IBAction)didClickedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)resetShareButtonStatus {
    NSDictionary *loginAvailability = [ThirdPartyLoginService loginTypeAvailablities];
    
    BOOL canLogin = NO;
//    canLogin = [[loginAvailability objectForKey:kThirdPartyLoginTypeWechat] boolValue];
//    if (canShare) {
//        [self. setEnabled:YES];
//        [self.wechatSessionTitleLabel setAlpha:1];
//    } else {
//        [self.wechatSessionButton setEnabled:NO];
//        [self.wechatSessionTitleLabel setAlpha:0.4];
//    }
//    canShare = [[loginAvailability objectForKey:kCommonShareTypeWechatTimeLineKey] boolValue];
//    if (canShare) {
//        [self.wechatTimeLineButton setEnabled:YES];
//        [self.wechatTimeLineTitleLabel setAlpha:1];
//    } else {
//        [self.wechatTimeLineButton setEnabled:NO];
//        [self.wechatTimeLineTitleLabel setAlpha:0.4];
//    }
    canLogin = [[loginAvailability objectForKey:kThirdPartyLoginTypeAlipay] boolValue];
    if (canLogin) {
        [self.alipayButton setEnabled:YES];
        [self.alipayLabel setAlpha:1];
    } else {
        [self.alipayButton setEnabled:NO];
        [self.alipayLabel setAlpha:0.4];
    }
    canLogin = [[loginAvailability objectForKey:kThirdPartyLoginTypeWeibo] boolValue];
    if (canLogin) {
        [self.weiboButton setEnabled:YES];
        [self.weiboLabel setAlpha:1];
    } else {
        [self.weiboButton setEnabled:NO];
        [self.weiboLabel setAlpha:0.4];
    }
    canLogin = [[loginAvailability objectForKey:kThirdPartyLoginTypeQQ] boolValue];
    if (canLogin) {
        [self.qqButton setEnabled:YES];
        [self.qqLabel setAlpha:1];
    } else {
        [self.qqButton setEnabled:NO];
        [self.qqLabel setAlpha:0.4];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
