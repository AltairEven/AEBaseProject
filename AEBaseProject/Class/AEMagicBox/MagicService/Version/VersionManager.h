//
//  VersionManager.h
//  ICSON
//
//  Created by 钱烨 on 2/26/15.
//  Copyright (c) 2015 肖晓春. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppIDInAppStore (@"")
#define URL_APP_STORE_UPDATE ([NSString stringWithFormat: @"http://itunes.apple.com/cn/app/id%@", kAppIDInAppStore])

@interface VersionManager : NSObject

@property (nonatomic, strong, readonly) NSString *version;

/*
 *brief:VersionManager实例
 *return:VersionManager实例
 */
+ (instancetype)sharedManager;

/**
 *  检查更新
 *
 *  @param result void
 */
- (void)checkAppVersionWithResult:(void(^)(BOOL needUpdate, BOOL forceUpdate, NSDictionary *versionInfo, NSError *error))result;

/*
 *brief:前往app store更新
 *return:void
 */
- (void)goToUpdateViaItunes;

/**
 *  是否在下次更新提醒时间间隔内
 *
 *  @param timeNow 时间入参
 *
 *  @return 是否在时间间隔内
 */
+ (BOOL)isInUpdateImmunePeriod:(NSDate *)timeNow;

/**
 *  重新设置下次更新提醒时间
 */
+ (void)resetUpdateImmunePeriod;

@end
