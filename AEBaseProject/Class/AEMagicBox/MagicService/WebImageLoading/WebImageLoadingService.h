//
//  WebImageLoadingService.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REVISEFLAG (@"WebImageLoadingStrategyRevised")

typedef enum {
    WebImageLoadingStrategyNoLoad = 1 << 0,
    WebImageLoadingStrategy2G = 1 << 1,
    WebImageLoadingStrategy3G = 1 << 2,
    WebImageLoadingStrategy4G = 1 << 3,
    WebImageLoadingStrategyWifi = 1 << 4,
    WebImageLoadingStrategyAllLoad = WebImageLoadingStrategy2G | WebImageLoadingStrategy3G | WebImageLoadingStrategy4G | WebImageLoadingStrategyWifi
}WebImageLoadingStrategy;

typedef enum {
    WebImageQualityEmptyImage,
    WebImageQuality1QuarterResolution,
    WebImageQualityHalfResolution,
    WebImageQuality3QuarterResolution,
    WebImageQualityFullResolution
}WebImageQuality;

extern NSString *const kWebImageQualityKey2G;
extern NSString *const kWebImageQualityKey3G;
extern NSString *const kWebImageQualityKey4G;
extern NSString *const kWebImageQualityKeyWifi;

@interface WebImageLoadingService : NSObject
/**
 *  图片加载策略，默认WebImageLoadingStrategyAllLoad（任何网络已连接的情况下，都加载图片）
 */
@property (nonatomic, assign) WebImageLoadingStrategy loadingStrategy;
/**
 *  图片质量策略，默认如下：
 *  kWebImageQualityKey2G:WebImageQualityHalfResolution
 *  kWebImageQualityKey3G:WebImageQualityFullResolution
 *  kWebImageQualityKey4G:WebImageQualityFullResolution
 *  kWebImageQualityKeyWifi:WebImageQualityFullResolution
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *qualityStrategy;
/**
 *  当前网络图片加载质量
 *  注：当qualityStrategy与loadingStrategy冲突，仍以loadingStrategy为准。
 （如loadingStrategy为WebImageLoadingStrategyNoLoad，而kWebImageQualityKeyWifi对应值为WebImageQualityFullResolution，则currentWebImageQuality为WebImageQualityEmptyImage）
 */
@property (nonatomic, readonly) WebImageQuality currentWebImageQuality;


/**
 *  单例方法
 *
 *  @return 类实例
 */
+ (instancetype)sharedInstance;
/**
 *  处理不同网络状态下的图片加载策略，并返回当前网络图片加载质量
 *
 *  @param status 网络状态
 *
 *  @return 加载图片的质量
 */
- (WebImageQuality)handleWebImageLoadingWithNetworkStatus:(AENetworkStatus)status;

@end

@interface WebImageLoadingService (ReimplementImageLoading)
/**
 *  支持的重写加载方法的类，默认SDWebImageDownloader(目前只支持SDWebImageDownloader)
 */
@property (nonatomic, copy) NSSet<NSString *> *reimplementedClasses;

@end

@interface NSURL (WebImageQuality)

@property (nonatomic, readonly) BOOL isWebImageLoadingServiceControlled;

@property (nonatomic, readonly) WebImageQuality quality;

- (NSURL *)revisedUrl;

- (NSURL *)unRevised;

@end
