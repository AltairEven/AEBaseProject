//
//  ApplicationServiceManager.m
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "ApplicationServiceManager.h"
#import "ApplicationSettingManager.h"

NSString *const kApplicationServiceTypeKey = @"kServiceType";

static ApplicationServiceManager *_sharedManager = nil;


@implementation ApplicationServiceManager

+ (instancetype)manager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedManager = [[ApplicationServiceManager alloc] init];
    });
    
    return _sharedManager;
}


- (ApplicationServiceType)currentServiceType {
    ApplicationServiceType type = ApplicationServiceTypeDevelop;
    if ([ApplicationSettingManager hasValidSettingFiles]) {
        NSNumber *typeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationServiceTypeKey];
        if (typeNumber) {
            type = (ApplicationServiceType)[typeNumber integerValue];
        }
    }
    return type;
}

@end
