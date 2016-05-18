//
//  ApplicationSettingManager.m
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import "ApplicationSettingManager.h"

#define BUNDLE_NAME (@"Settings")

static ApplicationSettingManager *_sharedManager = nil;

@implementation ApplicationSettingManager

+ (instancetype)manager {
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedManager = [[ApplicationSettingManager alloc] init];
    });
    
    return _sharedManager;
}


+ (BOOL)hasValidSettingFiles {
    NSString *settingBundle = [ApplicationSettingManager pathForSettingBundle];
    if (!settingBundle) {
        return NO;
    }
    return YES;
}


+ (NSString *)pathForSettingBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:BUNDLE_NAME ofType:@"bundle"];
    return settingsBundle;
}

@end
