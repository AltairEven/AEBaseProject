//
//  VersionManager.m
//  ICSON
//
//  Created by 钱烨 on 2/26/15.
//  Copyright (c) 2015 肖晓春. All rights reserved.
//

#import "VersionManager.h"


NSString *const kUpdateImmunePeriodKey = @"kUpdateImmunePeriodKey";
NSString *const kForceUpdateInfoKey = @"kForceUpdateInfoKey";
static const NSTimeInterval kUpdateImmuneTimeThreshold = 60.0f * 60 * 24 * 3;

static VersionManager *_versionManager = nil;

@interface VersionManager ()

@property (nonatomic, strong) HttpRequestClient *checkVersionRequest;


@end

@implementation VersionManager
@synthesize version = _version;
@synthesize checkVersionRequest;

- (id)init
{
    self = [super init];
    if (self) {
        _version = [AEToolUtil currentAppVersion];
    }
    return self;
}


+ (instancetype)sharedManager
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^{
        _versionManager = [[VersionManager alloc] init];
    });
    
    return _versionManager;
}

- (void)checkAppVersionWithResult:(void (^)(BOOL, BOOL, NSDictionary *, NSError *))result {
    
}


- (void)goToUpdateViaItunes
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_APP_STORE_UPDATE]];
}

+ (BOOL)isInUpdateImmunePeriod:(NSDate *)timeNow {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDate *updateImmunePeriodStartDate = [prefs objectForKey:kUpdateImmunePeriodKey];
    if (updateImmunePeriodStartDate == nil)
    {
        return NO;
    }
    
    return [timeNow timeIntervalSinceDate:updateImmunePeriodStartDate] < kUpdateImmuneTimeThreshold;
}

+ (void)resetUpdateImmunePeriod {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUpdateImmunePeriodKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
