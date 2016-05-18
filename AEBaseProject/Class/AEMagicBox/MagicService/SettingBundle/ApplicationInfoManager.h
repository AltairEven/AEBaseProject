//
//  ApplicationInfoManager.h
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kApplicationVersionKey;
extern NSString *const kBuildVersionKey;

@interface ApplicationInfoManager : NSObject

+ (instancetype)manager;

+ (void)setupApplicationInfo;

@end
