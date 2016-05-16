//
//  MWPhoto+AUIExtension.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/9.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "MWPhoto+AUIExtension.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import "SDWebImageDecoder.h"
//#import "SDWebImageManager.h"
//#import "SDWebImageOperation.h"

@implementation MWPhoto (AUIExtension)

const NSString *resourceTypeKey = @"resourceTypeKey";
const NSString *webImageOperationKey = @"webImageOperationKey";
const NSString *assetRequestIDKey = @"assetRequestIDKey";

- (void)setResourceType:(MWPhotoResourceType)resourceType {
    objc_setAssociatedObject(self, &resourceTypeKey, [NSNumber numberWithInteger:resourceType], OBJC_ASSOCIATION_ASSIGN);
}

- (MWPhotoResourceType)resourceType {
    NSNumber *typeNumber = objc_getAssociatedObject(self, &resourceTypeKey);
    NSInteger typeInt = [typeNumber integerValue];
    MWPhotoResourceType type = MWPhotoResourceTypeUnknown;
    if (typeInt >= MWPhotoResourceTypeUnknown && typeInt <= MWPhotoResourceTypePHAsset) {
        type = (MWPhotoResourceType)typeInt;
    }
    return type;
}

- (void)setWebImageOperation:(id<SDWebImageOperation>)webImageOperation {
    objc_setAssociatedObject(self, &webImageOperationKey, webImageOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SDWebImageOperation>)webImageOperation {
    return objc_getAssociatedObject(self, &webImageOperationKey);
}

- (void)setAssetRequestID:(PHImageRequestID)assetRequestID {
    objc_setAssociatedObject(self, &assetRequestIDKey, [NSNumber numberWithInteger:assetRequestID], OBJC_ASSOCIATION_ASSIGN);
}

- (PHImageRequestID)assetRequestID {
    NSNumber *idNumber = objc_getAssociatedObject(self, &assetRequestIDKey);
    PHImageRequestID idInt = [idNumber intValue];
    return idInt;
}

+ (CGSize)defaultFullScreenTargetSizeForAlbumPhoto {
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    // Sizing is very rough... more thought required in a real implementation
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height);
    
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    return imageTargetSize;
}

+ (CGSize)defaultThumbnailTargetSizeForAlbumPhoto {
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    // Sizing is very rough... more thought required in a real implementation
    CGFloat imageSize = MAX(screen.bounds.size.width / 2, screen.bounds.size.height / 2);
    
    CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
    return thumbTargetSize;
}

- (void)loadImageWithResult:(void (^)(UIImage *, CGFloat, NSError *))loadResult {
    if (!loadResult) {
        return;
    }
    switch (self.resourceType) {
        case MWPhotoResourceTypeUnknown:
        {
            NSError *error = [NSError errorWithDomain:@"MWPhoto load image" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Unknown resource type" forKey:@"errMsg"]];
            loadResult(nil, 1, error);
        }
            break;
        case MWPhotoResourceTypeRealImage:
        {
            UIImage *image = [self valueForKey:@"image"];
            loadResult(image, 1, nil);
        }
            break;
        case MWPhotoResourceTypeUrl:
        {
            [self loadImageWithUrl:[self valueForKey:@"photoURL"] result:loadResult];
        }
            break;
        case MWPhotoResourceTypePHAsset:
        {
            PHAsset *asset = [self valueForKey:@"asset"];
            
            NSValue *sizeValue = [self valueForKey:@"assetTargetSize"];
            CGSize targetSize = [sizeValue CGSizeValue];
            
            [self loadImageWithPHAsset:asset targetSize:targetSize result:loadResult];
        }
            break;
        default:
            break;
    }
}

- (void)loadImageWithUrl:(NSURL *)url result:(void (^)(UIImage *, CGFloat, NSError *))loadResult {
    if (!loadResult) {
        return;
    }
    // Check what type of url it is
    if ([[[url scheme] lowercaseString] isEqualToString:@"assets-library"]) {
        // Load from assets library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                    [assetslibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset){
                                       ALAssetRepresentation *rep = [asset defaultRepresentation];
                                       CGImageRef iref = [rep fullScreenImage];
                                       UIImage *image = nil;
                                       if (iref) {
                                           image = [UIImage imageWithCGImage:iref];
                                       }
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           loadResult(image, 1, nil);
                                       });
                                   }
                                  failureBlock:^(NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          loadResult(nil, 0, error);
                                      });
                                  }];
                } @catch (NSException *e) {
                    NSError *error = [NSError errorWithDomain:@"MWPhoto load image" code:-1 userInfo:e.userInfo];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loadResult(nil, 0, error);
                    });
                }
            }
        });
    } else if ([url isFileReferenceURL]) {
        // Load from local file async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                UIImage *image = [UIImage imageWithContentsOfFile:url.path];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loadResult(image, 1, nil);
                    });
                } else {
                    NSError *error = [NSError errorWithDomain:@"MWPhoto load image" code:-1 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Error loading photo from path: %@", url.path] forKey:@"errMsg"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loadResult(nil, 0, error);
                    });
                }
            }
        });
    } else {
        // Load async from web (using SDWebImage)
        @try {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            self.webImageOperation = [manager downloadImageWithURL:[url revisedUrl]
                                                      options:0
                                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                          if (expectedSize > 0) {
                                                              float progress = receivedSize / (float)expectedSize;
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  loadResult(nil, progress, nil);
                                                              });
                                                          }
                                                      }
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                         if (error) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 loadResult(nil, 0, error);
                                                             });
                                                         }
                                                        self.webImageOperation = nil;
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            loadResult(image, 1, nil);
                                                         });
                                                     }];
        } @catch (NSException *e) {
            self.webImageOperation = nil;
            NSError *error = [NSError errorWithDomain:@"MWPhoto load image" code:-1 userInfo:e.userInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                loadResult(nil, 0, error);
            });
        }
    }
}

- (void)loadImageWithPHAsset:(PHAsset *)asset targetSize:(CGSize)size result:(void (^)(UIImage *, CGFloat, NSError *))loadResult {
    if (!loadResult) {
        return;
    }
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            loadResult(nil, progress, nil);
        });
    };
    
    self.assetRequestID = [imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            loadResult(result, 1, [info objectForKey:PHImageErrorKey]);
        });
    }];
}

- (void)cancelLoadingImage {
    [self cancelAnyLoading];
    if (self.webImageOperation) {
        [self.webImageOperation cancel];
        self.webImageOperation = nil;
    }
    if (self.assetRequestID != PHInvalidImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.assetRequestID];
        self.assetRequestID = PHInvalidImageRequestID;
    }
}

@end
