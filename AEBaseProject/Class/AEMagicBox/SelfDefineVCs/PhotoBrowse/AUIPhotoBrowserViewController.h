//
//  AUIPhotoBrowserViewController.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/5.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MWPhoto+AUIExtension.h"

@class AUIPhotoBrowserViewController;

@protocol AUIPhotoBrowserViewControllerDelegate <NSObject, MWPhotoBrowserDelegate>

@optional

- (void)photoBrowser:(AUIPhotoBrowserViewController *)photoBrowser willStartFetchingAlbumMediaWithType:(PHAssetMediaType)type;

/**
 *  当本地相册资源加载完后，回调给代理
 *
 *  @param photoBrowser     photoBrowser
 *  @param type             加载的本地相册资源类型
 *  @param fullScreenPhotos 用于全屏展示的图片，没有数据则为nil
 *  @param thumbnailPhotos  用于缩略图展示的图片，没有数据则为nil
 *
 *  @return 是否需要AUIPhotoBrowserViewController装载数据
 */
- (BOOL)photoBrowser:(AUIPhotoBrowserViewController *)photoBrowser didFinishedFetchingAlbumMediaWithType:(PHAssetMediaType)type fullScreenPhotos:(NSArray<MWPhoto *> *)fullScreenPhotos thumbnailPhotos:(NSArray<MWPhoto *> *)thumbnailPhotos;

- (void)photoBrowserDidReachedMaxSelection:(AUIPhotoBrowserViewController *)photoBrowser;

- (void)photoBrowserWillDisappear:(MWPhotoBrowser *)photoBrowser;

- (void)photoBrowserDidDisappear:(MWPhotoBrowser *)photoBrowser;

@end

@class AUIPhotoBrowserViewController;

@interface AUIPhotoBrowserViewController : MWPhotoBrowser

@property (nonatomic, weak) id<AUIPhotoBrowserViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSUInteger selectedCount;

@property (nonatomic, assign) NSUInteger maxSelectCount;

/**
 *  初始化方法，可自动加载本地相册中对应PHAssetMediaType类型的内容，加载的内容会通过代理photoBrowser:didFinishedFetchingAlbumMediaWithTypefullScreenPhotos:thumbnailPhotos:方法回调。（遵循AUIPhotoBrowserViewControllerDelegate协议的对象，需要自行管理和保存加载内容，本类实例不负责管理和保存，以防止不必要的内存占用。）
 *
 *  @param type 媒体类型，PHAssetMediaTypeUnknown表示全部
 *  @param need 是否需要自动加载本地相册内容
 *  @param show 是否显示栅格
 *
 *  @return 类实例
 */
+ (instancetype)browserWithAlbumMediaType:(PHAssetMediaType)type needAutoLoad:(BOOL)need showGrid:(BOOL)show;

/**
 *  默认的图片浏览实例
 *
 *  @return 类实例
 */
+ (instancetype)defaultBrowser;

@end
