//
//  AEPushNotificationService.m
//  AEAssistant_Manager
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AEPushNotificationService.h"

#define kDeviceToken (@"device_token")

NSString *const kRemotePushNeedSegueNotification = @"kRemotePushNeedSegueNotification";

static AEPushNotificationService *sharedInstance = nil;

@interface AEPushNotificationService ()

@property (nonatomic, strong) HttpRequestClient *setAccountRequest;

@property (nonatomic, strong) HttpRequestClient *checkUnreadRequest;

@property (nonatomic, strong) HttpRequestClient *readMessageRequest;

- (NSUInteger)checkUnreadMessageSucceed:(NSDictionary *)data;

@end

@implementation AEPushNotificationService

+ (instancetype)sharedService {
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [[AEPushNotificationService alloc] init];
    });
    return sharedInstance;
}

#pragma mark Register

- (void)launchServiceWithOption:(NSDictionary *)launchOptions {
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self handlePushPayload:userInfo];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self registerNotification];
}

- (void)registerNotification
{
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (NSString *)registerDevice:(NSData *)deviceToken {
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@", deviceToken];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceTokenStr = [deviceTokenStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    [[NSUserDefaults standardUserDefaults] setValue:deviceTokenStr forKey:kDeviceToken];
    _token = deviceTokenStr;
    [self bindAccount:YES];
    
    return deviceTokenStr;
}

- (void)handleRegisterDeviceFailure:(NSError *)error {
    LOG(@"Push Register Error:%@", error.description);
}

#pragma mark Account

- (void)bindAccount:(BOOL)bind {
    if (!self.setAccountRequest) {
        self.setAccountRequest = [HttpRequestClient clientWithUrlAliasName:@"PUSH_REGISTER_DEVICE"];
    } else {
        [self.setAccountRequest cancel];
    }
    NSUInteger type = 2;//解绑
    if (bind) {
        type = 1;//绑定
    }
    if ([self.token length] == 0) {
        _token = [[NSUserDefaults standardUserDefaults] objectForKey:kDeviceToken];
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:type], @"type", self.token, @"deviceId", nil];
    __weak typeof(self) weakSelf = self;
    [weakSelf.setAccountRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSLog(@"Push Set Account:%@", responseData);
    } failure:^(HttpRequestClient *client, NSError *error) {
        NSLog(@"Push Set Account:%@", error);
    }];
}

#pragma mark Handle Notification

- (void)handleApplication:(UIApplication *)application withReceivedNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    [self dealRemoteNotification:userInfo appState:state];
}

- (void)dealRemoteNotification:(NSDictionary *)payload appState:(UIApplicationState)state{
    NSDictionary * aps = [payload objectForKey:@"aps"];
    
    if (state == UIApplicationStateActive) {
        NSString * title = [payload objectForKey:@"title"] ? [payload objectForKey:@"title"] : @"消息";
        NSString * msg = [aps objectForKey:@"alert"] ? [aps objectForKey:@"alert"] : @"您有新的消息!";
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *leftAction = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *rightAction = [UIAlertAction actionWithTitle:@"立即查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handlePushPayload:payload];
        }];
        [controller addAction:leftAction];
        [controller addAction:rightAction];
        [[AETabBarController sharedTabBarController] presentViewController:controller animated:YES completion:nil];
    } else {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if([app.window.rootViewController isKindOfClass:[AETabBarController class]]) {
            [self handlePushPayload:payload];
        } else {
            //程序正在启动
            double delayInSeconds = 0.3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self handlePushPayload:payload];
            });
        }
    }
    
}

- (void)handlePushPayload:(NSDictionary *)payload {
    PushNotificationModel *model = [[PushNotificationModel alloc] initWithRemoteNotificationData:payload];
    if (!model || model.segueModel.destination == HomeSegueDestinationNone) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRecievedRemoteNotificationWithModel:)]) {
        [self.delegate didRecievedRemoteNotificationWithModel:model];
    }
}


#pragma mark Read Status

- (void)checkUnreadMessage:(void (^)(NSUInteger))succeed failure:(void (^)(NSError *))failure {
    if (!self.checkUnreadRequest) {
        self.checkUnreadRequest = [HttpRequestClient clientWithUrlAliasName:@"PUSH_IS_UN_READ_MESSAGE"];
    } else {
        [self.checkUnreadRequest cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.checkUnreadRequest startHttpRequestWithParameter:nil success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSUInteger unreadCount = [weakSelf checkUnreadMessageSucceed:responseData];
        if (succeed) {
            succeed(unreadCount);
        }
    } failure:^(HttpRequestClient *client, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)readMessageWithIdentifier:(NSString *)identifier {
    if (!self.readMessageRequest) {
        self.readMessageRequest = [HttpRequestClient clientWithUrlAliasName:@"PUSH_USER_READ_MESSAGE"];
    } else {
        [self.readMessageRequest cancel];
    }
    NSDictionary *param = [NSDictionary dictionaryWithObject:identifier forKey:@"ids"];
    
    [self.readMessageRequest startHttpRequestWithParameter:param success:^(HttpRequestClient *client, NSDictionary *responseData) {
        NSLog(@"Set read status succeed.");
    } failure:^(HttpRequestClient *client, NSError *error) {
        NSLog(@"Set read status failed.");
    }];
}

#pragma mark Private methods

- (NSUInteger)checkUnreadMessageSucceed:(NSDictionary *)data {
    NSDictionary *countDic = [data objectForKey:@"data"];
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return 0;
    }
    NSUInteger count = [[countDic objectForKey:@"count"] integerValue];
    _unreadCount = count;
    NSUInteger tabCount = [[AETabBarController sharedTabBarController] tabCount];
    if (count == 0) {
        [[AETabBarController sharedTabBarController] setBadge:nil forTabIndex:tabCount - 1];
    } else {
        //        NSString *badgeString = [NSString stringWithFormat:@"%lu", (unsigned long)count];
        [[AETabBarController sharedTabBarController] setBadge:@"" forTabIndex:tabCount - 1];
    }
    return count;
}

@end
