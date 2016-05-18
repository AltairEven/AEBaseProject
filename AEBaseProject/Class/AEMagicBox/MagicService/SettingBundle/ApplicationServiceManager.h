//
//  ApplicationServiceManager.h
//  PingYu
//
//  Created by Qian Ye on 16/4/27.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ApplicationServiceTypeDevelop,
    ApplicationServiceTypeTest,
    ApplicationServiceTypeDistribution
}ApplicationServiceType;

extern NSString *const kApplicationServiceTypeKey;

@interface ApplicationServiceManager : NSObject

+ (instancetype)manager;

- (ApplicationServiceType)currentServiceType;

@end
