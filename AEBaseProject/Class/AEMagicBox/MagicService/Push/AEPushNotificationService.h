//
//  AEPushNotificationService.h
//  AEAssistant_Manager
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AEPushNotificationService;

@protocol AEPushNotificationServiceDelegate <NSObject>

- (void)didRecievedRemoteNotificationWithModel:(PushNotificationModel *)model;

@end

@interface AEPushNotificationService : NSObject

@property (nonatomic, assign) id<KTCPushNotificationServiceDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *token;

@property (nonatomic, readonly) BOOL isOnLine;

@property (nonatomic, assign) NSUInteger unreadCount;

+ (instancetype)sharedService;

- (NSString *)registerDevice:(NSData *)deviceToken;

- (void)handleRegisterDeviceFailure:(NSError *)error;

- (void)bindAccount:(BOOL)bind;

- (void)launchServiceWithOption:(NSDictionary *)launchOptions;

- (void)handleApplication:(UIApplication *)application withReceivedNotification:(NSDictionary *)userInfo;

- (void)checkUnreadMessage:(void(^)(NSUInteger unreadCount))succeed failure:(void(^)(NSError *error))failure;

- (void)readMessageWithIdentifier:(NSString *)identifier;

@end
