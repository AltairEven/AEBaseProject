//
//  MWPhoto+AUIExtension.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/9.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "MWPhoto.h"

typedef enum {
    MWPhotoResourceTypeUnknown,
    MWPhotoResourceTypeRealImage,
    MWPhotoResourceTypeUrl,
    MWPhotoResourceTypePHAsset
}MWPhotoResourceType;

@interface MWPhoto (AUIExtension)

@property (nonatomic, assign) MWPhotoResourceType resourceType;

+ (CGSize)defaultFullScreenTargetSizeForAlbumPhoto;

+ (CGSize)defaultThumbnailTargetSizeForAlbumPhoto;

/**
 *  加载MWPhoto关联的图片
 *
 *  @param result 结果回调。
                image:图片，加载进行中，则为nil
                progress:进度
                error:错误信息
                stop:外部传入，标示是否停止
 */
- (void)loadImageWithResult:(void(^)(UIImage *image, CGFloat progress, NSError *error))loadResult;

/**
 *  取消加载MWPhoto关联的图片
 */
- (void)cancelLoadingImage;

@end
