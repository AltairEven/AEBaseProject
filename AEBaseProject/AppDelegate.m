//
//  AppDelegate.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/3.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AppDelegate.h"
#import "GuideViewController.h"
#import "LoadingViewController.h"
#import "AEPushNotificationService.h"
#import "VersionManager.h"
#import "ApplicationSettingManager.h"

static BOOL _alreadyLaunched = NO;

@interface AppDelegate () <AEPushNotificationServiceDelegate>

+ (void)handleNetworkStatusChange:(AENetworkStatus)status;

- (void)showLoading;
- (void)showWelcome;

- (void)showUpdateAlertViewWithInfo:(NSDictionary *)info forceUpdate:(BOOL)force;

//flash
@property (nonatomic, assign) BOOL canShowAdvertisement;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[WebImageLoadingService sharedInstance] setLoadingStrategy:WebImageLoadingStrategyAllLoad];
    
    AEReachability *manager = [AEReachability sharedInstance];
    [manager startNetworkMonitoringWithStatusChangeBlock:^ (AENetworkStatus status) {
        [AppDelegate handleNetworkStatusChange:status];
        _alreadyLaunched = YES;
    }];
    
    [[InterfaceManager sharedManager] updateInterface];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    //tabbar
    AETabBarController *tabbar = [AETabBarController sharedTabBarController];
    [tabbar  createViewControllers];
    self.window.rootViewController = tabbar;
    //show welcome
    [self showWelcome];
    //    //处理通知
//    [AEPushNotificationService sharedService].delegate = self;
//    [[AEPushNotificationService sharedService] launchServiceWithOption:launchOptions];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ApplicationInfoManager setupApplicationInfo];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[GAlertLoadingView sharedAlertLoadingView] hide];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //把通知的badgeNumber设置为0
    application.applicationIconBadgeNumber = 0;
    
    [self showAdvertisement];
    //版本检查更新
    [self checkVersion];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark OpenUrl

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    if ([url.scheme isEqualToString:kAlipayFromScheme])
//    {
//        return [[AlipayManager sharedManager] handleOpenUrl:url];
//    }
//    else if ([url.scheme isEqualToString:kWeChatUrlScheme])
//    {
//        return [[WeChatManager sharedManager] handleOpenURL:url];
//    }
//    else if ([url.scheme isEqualToString:kTencentUrlScheme])
//    {
//        return [[TencentManager sharedManager] handleOpenURL:url];
//    } else if ([url.scheme isEqualToString:kWeiboUrlScheme]) {
//        return [[WeiboManager sharedManager] handleOpenURL:url];
//    }
    
    return YES;
}


#pragma mark Notification ---------------------------------------------------------------------------------------


#pragma mark Local Notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif
{
    application.applicationIconBadgeNumber = 0;
}

#pragma mark Remote Notification

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[AEPushNotificationService sharedService] handleApplication:application withReceivedNotification:userInfo];
}

#pragma mark Register Remote Notification

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

// Receive deviceToken
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[AEPushNotificationService sharedService] registerDevice:deviceToken];
}

// Get deviceToken Error
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    [[AEPushNotificationService sharedService] handleRegisterDeviceFailure:err];
}

#pragma mark AEPushNotificationServiceDelegate

- (void)didRecievedRemoteNotificationWithModel:(PushNotificationModel *)model {
    if (!model) {
        return;
    }
    self.canShowAdvertisement = NO;
    //获取当前VC
    UINavigationController *controller = [AETabBarController sharedTabBarController].selectedViewController;
    controller.topViewController.view.tag = NotificationSegueTag;
    
    //展示消息跳转页面
    [AESegueMaster makeSegueWithModel:model.segueModel fromController:controller.topViewController];
}


#pragma mark Private Methods ------------------------------------------------------------------------------------

#pragma mark Version

- (void)checkVersion {
    __weak typeof(self) weakSelf = self;
    [[VersionManager sharedManager] checkAppVersionWithResult:^(BOOL needUpdate, BOOL forceUpdate, NSDictionary *versionInfo, NSError *error) {
        if (needUpdate) {
            if (forceUpdate) {
                [weakSelf showUpdateAlertViewWithInfo:versionInfo forceUpdate:YES];
            } else {
                if ([VersionManager isInUpdateImmunePeriod:[NSDate date]]) {
                    return;
                } else {
                    [weakSelf showUpdateAlertViewWithInfo:versionInfo forceUpdate:NO];
                }
            }
        }
    }];
}

- (void)showUpdateAlertViewWithInfo:(NSDictionary *)info forceUpdate:(BOOL)force
{
    NSString *newVersionName = [info objectForKey:@"newVersion"];
    NSString *descStr = [info objectForKey:@"description"];
    NSString *cancelStr = force ? @"退出" : @"稍后再说";
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本 %@", newVersionName] message:descStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leftAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (force) {
            [self exitApplication];
        }
    }];
    UIAlertAction *rightAction = [UIAlertAction actionWithTitle:@"立即去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[VersionManager sharedManager] goToUpdateViaItunes];
        if (!force) {
            [VersionManager resetUpdateImmunePeriod];
        }
    }];
    [controller addAction:leftAction];
    [controller addAction:rightAction];
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark Loading & Welcome

- (void)showLoading {
    LoadingViewController *loadingVC = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    self.welcomeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.welcomeWindow setBackgroundColor:[UIColor clearColor]];
    self.welcomeWindow.rootViewController = loadingVC;
    self.welcomeWindow.windowLevel = UIWindowLevelAlert + 1;
    //    [self.window setHidden:YES];
    //    [self.window setAlpha:0.7];
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.welcomeWindow makeKeyAndVisible];
    
    [loadingVC setLoad_complete:^(){
        //显示页面
        [self showRealWindow];
    }];
    [self showRealWindow];
}


- (void)showAdvertisement {
    if (!self.canShowAdvertisement) {
        return;
    }
    [self showRealWindow];
    //    NSArray *adItems = [[KTCAdvertisementManager sharedManager] advertisementImages];
    //    if ([adItems count] > 0) {
    //        BigAdvertisementViewController *adVC = [[BigAdvertisementViewController alloc] initWithAdvertisementItems:adItems];
    //        if (!self.welcomeWindow) {
    //            self.welcomeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //            [self.welcomeWindow setBackgroundColor:[UIColor clearColor]];
    //            self.welcomeWindow.windowLevel = UIWindowLevelAlert + 1;
    //        }
    //        self.welcomeWindow.rootViewController = adVC;
    //        [UIApplication sharedApplication].statusBarHidden = YES;
    //        if (![self.welcomeWindow isKeyWindow]) {
    //            [self.welcomeWindow makeKeyAndVisible];
    //        }
    //        //        [self.window setHidden:YES];
    //        //        [self.window setAlpha:0.7];
    //        __weak AppDelegate *weakSelf = self;
    //
    //        [adVC setCompletionBlock:^(HomeSegueModel *segueModel){
    //            [weakSelf showRealWindow];
    //            if (segueModel) {
    //                UINavigationController *controller = [KTCTabBarController shareTabBarController].selectedViewController;
    //
    //                //展示消息跳转页面
    //                [KTCSegueMaster makeSegueWithModel:segueModel fromController:controller.topViewController];
    //            }
    //        }];
    //        [[KTCAdvertisementManager sharedManager] setAlreadyShowed];
    //    } else {
    //        [self showRealWindow];
    //    }
}


- (void)showWelcome {
    if ([GuideViewController needShow]) {
        //第一次安装
        GuideViewController *guideVC = [[GuideViewController alloc] init];
        if (!self.welcomeWindow) {
            self.welcomeWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [self.welcomeWindow setBackgroundColor:[UIColor clearColor]];
            self.welcomeWindow.windowLevel = UIWindowLevelAlert + 1;
        }
        self.welcomeWindow.rootViewController = guideVC;
        [UIApplication sharedApplication].statusBarHidden = YES;
        if (![self.welcomeWindow isKeyWindow]) {
            [self.welcomeWindow makeKeyAndVisible];
        }
        __weak UIWindow *weakWelcome = self.welcomeWindow;
        __weak UIWindow *weakWindow = self.window;
        [guideVC setGuide_complete:^(){
            [weakWindow makeKeyAndVisible];
            [UIView animateWithDuration:0.5 animations:^{
                [weakWelcome setAlpha:0];
                [weakWindow setHidden:NO];
                [weakWindow setAlpha:1];
            } completion:^(BOOL finished) {
                [weakWelcome setHidden:YES];
                [weakWelcome setAlpha:1];
                weakWelcome.rootViewController = nil;
            }];
            [self showLoading];
            [GuideViewController setHasDisplayed];
        }];
    } else {
        [self showLoading];
    }
}

- (void)showRealWindow {
    __weak UIWindow *weakWelcome = self.welcomeWindow;
    __weak UIWindow *weakWindow = self.window;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [weakWelcome setAlpha:0];
        [weakWindow setHidden:NO];
        [weakWindow setAlpha:1];
    } completion:^(BOOL finished) {
        [weakWelcome setHidden:YES];
        [weakWelcome setAlpha:1];
        weakWelcome.rootViewController = nil;
    }];
    [AEToolUtil setHasFirstLaunched:YES];
}

#pragma mark Network Status

+ (void)handleNetworkStatusChange:(AENetworkStatus)status {
    //图片加载策略
    [[WebImageLoadingService sharedInstance] handleWebImageLoadingWithNetworkStatus:status];
    switch (status) {
        case AENetworkStatusUnknown:
        case AENetworkStatusNotReachable:
        {
            [[GAlertLoadingView sharedAlertLoadingView] hide];
            [[[iToast makeText:@"您当前网络不可用，请检查网络设置"] setDuration:1500] show];
        }
            break;
        case AENetworkStatusCellType2G:
        {
            if (!_alreadyLaunched) {
                return;
            }
            [[[iToast makeText:@"当前为2G蜂窝移动网络，请注意流量消耗"] setDuration:1500] show];
        }
            break;
        case AENetworkStatusCellType3G:
        {
            if (!_alreadyLaunched) {
                return;
            }
            [[[iToast makeText:@"当前为3G蜂窝移动网络，请注意流量消耗"] setDuration:1500] show];
        }
            break;
        case AENetworkStatusCellType4G:
        {
            if (!_alreadyLaunched) {
                return;
            }
            [[[iToast makeText:@"当前为4G蜂窝移动网络，请注意流量消耗"] setDuration:1500] show];
        }
            break;
        case AENetworkStatusReachableViaWiFi:
        {
            if (!_alreadyLaunched) {
                return;
            }
            [[[iToast makeText:@"当前为WIFI网络，祝您使用愉快"] setDuration:1500] show];
        }
            break;
        default:
            break;
    }
}

#pragma mark Exit

- (void)exitApplication {
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    self.window.alpha = 0;
    [UIView commitAnimations];
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

@end
