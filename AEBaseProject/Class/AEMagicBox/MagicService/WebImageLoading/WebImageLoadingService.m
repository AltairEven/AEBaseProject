//
//  WebImageLoadingService.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "WebImageLoadingService.h"
#import <objc/runtime.h>


NSString *const kWebImageQualityKey2G = @"kWebImageQualityKey2G";
NSString *const kWebImageQualityKey3G = @"kWebImageQualityKey3G";
NSString *const kWebImageQualityKey4G = @"kWebImageQualityKey4G";
NSString *const kWebImageQualityKeyWifi = @"kWebImageQualityKeyWifi";

@interface WebImageLoadingService ()

@end

@implementation WebImageLoadingService

+ (instancetype)sharedInstance {
    static WebImageLoadingService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebImageLoadingService alloc] init];
        sharedInstance.loadingStrategy = WebImageLoadingStrategyAllLoad;
        sharedInstance.qualityStrategy = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @(WebImageQualityHalfResolution), kWebImageQualityKey2G,
                                          @(WebImageQualityFullResolution), kWebImageQualityKey3G,
                                          @(WebImageQualityFullResolution), kWebImageQualityKey4G,
                                          @(WebImageQualityFullResolution), kWebImageQualityKeyWifi, nil];
        [sharedInstance setReimplementedClasses:[NSSet setWithObject:@"SDWebImageDownloader"]];
    });
    return sharedInstance;
}

- (WebImageQuality)handleWebImageLoadingWithNetworkStatus:(AENetworkStatus)status {
    WebImageLoadingStrategy strategyAssumption = WebImageLoadingStrategyNoLoad;
    NSString *qualityKey = nil;
    
    switch (status) {
        case AENetworkStatusUnknown:
        case AENetworkStatusNotReachable:
            break;
        case AENetworkStatusCellType2G:
        {
            strategyAssumption = WebImageLoadingStrategy2G;
            qualityKey = kWebImageQualityKey2G;
        }
            break;
        case AENetworkStatusCellType3G:
        {
            strategyAssumption = WebImageLoadingStrategy3G;
            qualityKey = kWebImageQualityKey3G;
        }
            break;
        case AENetworkStatusCellType4G:
        {
            strategyAssumption = WebImageLoadingStrategy4G;
            qualityKey = kWebImageQualityKey4G;
        }
            break;
        case AENetworkStatusReachableViaWiFi:
        {
            strategyAssumption = WebImageLoadingStrategyWifi;
            qualityKey = kWebImageQualityKeyWifi;
        }
            break;
        default:
            break;
    }
    
    WebImageLoadingStrategy resultStrategy = strategyAssumption & self.loadingStrategy;
    if (resultStrategy != strategyAssumption) {
        //不在策略设置项中
        resultStrategy = WebImageLoadingStrategyNoLoad;
    }
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        if (resultStrategy == WebImageLoadingStrategyNoLoad || !qualityKey) {
            //不加载，或无效的加载KEY
            _currentWebImageQuality = WebImageQualityEmptyImage;
        } else {
            _currentWebImageQuality = (WebImageQuality)[[self.qualityStrategy objectForKey:qualityKey] integerValue];
        }
    });
    
    return _currentWebImageQuality;
}


@end


@implementation WebImageLoadingService (ReimplementImageLoading)

static const char *kReimplementedClassesKey = "kReimplementedClassesKey";

- (void)setReimplementedClasses:(NSSet<NSString *> *)reimplementedClasses {
    NSMutableSet *tempSet = [reimplementedClasses mutableCopy];
    [reimplementedClasses enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"SDWebImageDownloader"]) {
            BOOL hasReimplemented = [self reimplementSDWebImageDownloader];
            if (!hasReimplemented) {
                [tempSet removeObject:obj];
            }
        }
    }];
    objc_setAssociatedObject(self, kReimplementedClassesKey, [tempSet copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSSet<NSString *> *)reimplementedClasses {
    return objc_getAssociatedObject(self, kReimplementedClassesKey);
}


- (BOOL)reimplementSDWebImageDownloader {
    //判断参数的有效性
    if (!class_respondsToSelector([SDWebImageDownloader class], @selector(downloadImageWithURL:options:progress:completed:))) {
        return NO;
    }
    //先复制一份旧方法实现
    Method oldMethod = class_getInstanceMethod([SDWebImageDownloader class], @selector(downloadImageWithURL:options:progress:completed:));
    if (!oldMethod) {
        return NO;
    }
    IMP oldImp = method_getImplementation(oldMethod);
    const char *types = method_getTypeEncoding(oldMethod);
    
    //为被改写的类，添加实现方法
    BOOL addSucceed = class_addMethod([SDWebImageDownloader class], @selector(reimplementedDownloadImageWithURL:options:progress:completed:), oldImp, types);
    if (!addSucceed) {
        return NO;
    }
    
    //然后交换新旧方法实现
    Method freshMethod = class_getInstanceMethod([self class], @selector(reimplementedDownloadImageWithURL:options:progress:completed:));
    method_exchangeImplementations(oldMethod, freshMethod);
    
    return YES;
}

- (id <SDWebImageOperation>)reimplementedDownloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageDownloaderOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    LOG(@"%@, isControlled:%d, quality:%d", url, url.isWebImageLoadingServiceControlled, url.quality);
    
    if (url.isWebImageLoadingServiceControlled && url.quality == WebImageQualityEmptyImage) {
        if (completedBlock) {
            NSError *error = [NSError errorWithDomain:@"WebImageLoadingService" code:-1 userInfo:@{@"errMsg":@"WebImageLoadingService denied"}];
            completedBlock(nil, nil, error, YES);
        }
        return nil;
    }
    
    return [self reimplementedDownloadImageWithURL:url options:options progress:progressBlock completed:completedBlock];
}

@end


@implementation NSURL (WebImageQuality)

static const char *kServiceControlledKey = "kServiceControlledKey";
static const char *kQualityKey = "kQualityKey";

- (void)setIsWebImageLoadingServiceControlled:(BOOL)isWebImageLoadingServiceControlled {
    NSNumber *isControlled = [NSNumber numberWithBool:isWebImageLoadingServiceControlled];
    objc_setAssociatedObject(self, kServiceControlledKey, isControlled, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isWebImageLoadingServiceControlled {
    NSNumber *isControlled = objc_getAssociatedObject(self, kServiceControlledKey);
    return [isControlled boolValue];
}

- (void)setQuality:(WebImageQuality)quality {
    NSNumber *isControlled = [NSNumber numberWithInteger:quality];
    objc_setAssociatedObject(self, kQualityKey, isControlled, OBJC_ASSOCIATION_ASSIGN);
}

- (WebImageQuality)quality {
    NSNumber *qlty = objc_getAssociatedObject(self, kQualityKey);
    return (WebImageQuality)[qlty integerValue];
}

- (NSURL *)revisedUrl {
    WebImageQuality imageQuality = [[WebImageLoadingService sharedInstance] currentWebImageQuality];
    self.isWebImageLoadingServiceControlled = YES;
    self.quality = imageQuality;
    
    switch (imageQuality) {
        case WebImageQualityEmptyImage:
        {
            
        }
            break;
        case WebImageQuality1QuarterResolution:
        {
            
        }
            break;
        case WebImageQualityHalfResolution:
        {
            
        }
            break;
        case WebImageQuality3QuarterResolution:
        {
            
        }
            break;
        case WebImageQualityFullResolution:
        {
            
        }
            break;
        default:
            break;
    }
    return self;
}

- (NSURL *)unRevised {
    self.isWebImageLoadingServiceControlled = NO;
    self.quality = WebImageQualityEmptyImage;
    return self;
}

@end
