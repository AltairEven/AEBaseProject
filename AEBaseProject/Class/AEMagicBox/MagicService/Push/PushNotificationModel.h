//
//  PushNotificationModel.h
//  KidsTC
//
//  Created by Altair on 11/30/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AESegueModel.h"

typedef enum {
    PushNotificationStatusUnknow = 0,
    PushNotificationStatusHasRead,
    PushNotificationStatusUnread
}PushNotificationStatus;

@interface PushNotificationModel : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *createTimeDescription;

@property (nonatomic, copy) NSString *updateTimeDescription;

@property (nonatomic, assign) PushNotificationStatus status;

@property (nonatomic, strong) AESegueModel *segueModel;

- (instancetype)initWithRawData:(NSDictionary *)data;

- (instancetype)initWithRemoteNotificationData:(NSDictionary *)data;

@end
