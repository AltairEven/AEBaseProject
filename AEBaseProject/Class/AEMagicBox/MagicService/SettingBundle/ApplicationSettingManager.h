//
//  ApplicationSettingManager.h
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationInfoManager.h"
#import "ApplicationServiceManager.h"

@interface ApplicationSettingManager : NSObject

+ (instancetype)manager;

+ (BOOL)hasValidSettingFiles;

+ (NSString *)pathForSettingBundle;

@end
