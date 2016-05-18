//
//  ApplicationInfoManager.m
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "ApplicationInfoManager.h"
#import "ApplicationSettingManager.h"

NSString *const kApplicationVersionKey = @"kApplicationVersion";
NSString *const kBuildVersionKey = @"kBuildVersion";

static ApplicationInfoManager *_sharedManager = nil;

@interface ApplicationInfoManager ()


@end

@implementation ApplicationInfoManager

+ (instancetype)manager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedManager = [[ApplicationInfoManager alloc] init];
    });
    
    return _sharedManager;
}

+ (void)setupApplicationInfo {
    if (![ApplicationSettingManager hasValidSettingFiles]) {
        return;
    }
    //app version
    [[NSUserDefaults standardUserDefaults] setObject:[AEToolUtil currentAppVersion] forKey:kApplicationVersionKey];
    
    //build version
    [[NSUserDefaults standardUserDefaults] setObject:[AEToolUtil currentAppBuildVersion] forKey:kBuildVersionKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
