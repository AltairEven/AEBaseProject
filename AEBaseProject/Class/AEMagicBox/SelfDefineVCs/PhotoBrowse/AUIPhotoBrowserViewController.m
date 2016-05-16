//
//  AUIPhotoBrowserViewController.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/5.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AUIPhotoBrowserViewController.h"
#import "MWPhotoBrowserPrivate.h"
#import "MWGridCell.h"
#import <objc/runtime.h>

@interface AUIPhotoBrowserViewController ()

@property (nonatomic, weak) id<AUIPhotoBrowserViewControllerDelegate> sonDelegate;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, assign) BOOL needFetchAlbumMediaAssets;

@property (nonatomic, assign) PHAssetMediaType assetMediaType;

- (void)prepareAlbumMediaAssets;

- (void)prepareAlbumPhotosWithAssets:(NSArray<PHAsset *> *)assets;

- (void)fullFillSuperMethods;

- (void)configSelection;

@end

@implementation AUIPhotoBrowserViewController
@dynamic delegate;

+ (instancetype)browserWithAlbumMediaType:(PHAssetMediaType)type needAutoLoad:(BOOL)need showGrid:(BOOL)show {
    AUIPhotoBrowserViewController *controller = [[AUIPhotoBrowserViewController alloc] init];
    controller.needFetchAlbumMediaAssets = need;
    controller.assetMediaType = type;
    
    controller.displayActionButton = YES;
    controller.displayNavArrows = YES;
    controller.displaySelectionButtons = YES;
    controller.alwaysShowControls = YES;
    controller.zoomPhotosToFill = YES;
    controller.enableGrid = YES;
    controller.startOnGrid = show;
    controller.enableSwipeToDismiss = NO;
    controller.autoPlayOnAppear = YES;
    
    return controller;
}

+ (instancetype)defaultBrowser {
    AUIPhotoBrowserViewController *controller = [[AUIPhotoBrowserViewController alloc] init];
    
    controller.displayActionButton = YES;
    controller.displayNavArrows = YES;
    controller.displaySelectionButtons = NO;
    controller.alwaysShowControls = YES;
    controller.zoomPhotosToFill = YES;
    controller.enableGrid = YES;
    controller.startOnGrid = NO;
    controller.enableSwipeToDismiss = NO;
    controller.autoPlayOnAppear = YES;
    
    return controller;
}

- (void)viewDidLoad {
    self.displayActionButton = NO;
    [self configSelection];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fullFillSuperMethods];
    [self prepareAlbumMediaAssets];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserWillDisappear:)]) {
        [self.delegate photoBrowserWillDisappear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidDisappear:)]) {
        [self.delegate photoBrowserDidDisappear:self];
    }
}

#pragma mark Setter & Getter

- (void)setDelegate:(id<AUIPhotoBrowserViewControllerDelegate>)delegate {
    [super setDelegate:delegate];
    _sonDelegate = delegate;
}

- (id<AUIPhotoBrowserViewControllerDelegate>)delegate {
    return _sonDelegate;
}

#pragma mark Private methods

- (void)prepareAlbumMediaAssets {
    if (!self.needFetchAlbumMediaAssets) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:willStartFetchingAlbumMediaWithType:)]) {
        [self.delegate photoBrowser:self willStartFetchingAlbumMediaWithType:self.assetMediaType];
    }
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *fetchResults = nil;
        if (self.assetMediaType == PHAssetMediaTypeUnknown) {
            fetchResults = [PHAsset fetchAssetsWithOptions:options];
        } else {
            fetchResults = [PHAsset fetchAssetsWithMediaType:self.assetMediaType options:options];
        }
        [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tempArray addObject:obj];
        }];
        if (fetchResults) {
            [self prepareAlbumPhotosWithAssets:[NSArray arrayWithArray:tempArray]];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didFinishedFetchingAlbumMediaWithType:fullScreenPhotos:thumbnailPhotos:)]) {
                BOOL needReload = [self.delegate photoBrowser:self didFinishedFetchingAlbumMediaWithType:_assetMediaType fullScreenPhotos:nil thumbnailPhotos:nil];
                if (needReload) {
                    [self reloadData];
                }
            }
        }
    });
}

- (void)prepareAlbumPhotosWithAssets:(NSArray<PHAsset *> *)assets {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *tempFullArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempThumbArray = [[NSMutableArray alloc] init];
        CGSize fullScreenSize = [MWPhoto defaultFullScreenTargetSizeForAlbumPhoto];
        CGSize thumnailSize = [MWPhoto defaultThumbnailTargetSizeForAlbumPhoto];
        for (PHAsset *asset in assets) {
            @autoreleasepool {
                MWPhoto *fullScreenPhoto = [MWPhoto photoWithAsset:asset targetSize:fullScreenSize];
                if (fullScreenPhoto) {
                    fullScreenPhoto.resourceType = MWPhotoResourceTypePHAsset;
                    [tempFullArray addObject:fullScreenPhoto];
                } else {
                    continue;
                }
                
                MWPhoto *thumbnailPhoto = [MWPhoto photoWithAsset:asset targetSize:thumnailSize];
                if (thumbnailPhoto) {
                    thumbnailPhoto.resourceType = MWPhotoResourceTypePHAsset;
                    [tempThumbArray addObject:thumbnailPhoto];
                } else {
                    continue;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didFinishedFetchingAlbumMediaWithType:fullScreenPhotos:thumbnailPhotos:)]) {
                BOOL needReload = [self.delegate photoBrowser:self didFinishedFetchingAlbumMediaWithType:_assetMediaType fullScreenPhotos:[NSArray arrayWithArray:tempFullArray] thumbnailPhotos:[NSArray arrayWithArray:tempThumbArray]];
                if (needReload) {
                    [self reloadData];
                }
            }
        });
    });
}

- (void)fullFillSuperMethods {
    //判断方法的有效性
    if (!class_respondsToSelector([MWPhotoBrowser class], @selector(selectedButtonTapped:))) {
    }
    //先复制一份旧方法实现
    Method oldMethod = class_getInstanceMethod([MWPhotoBrowser class], @selector(selectedButtonTapped:));
    if (!oldMethod) {
        return;
    }
    
    //然后交换新旧方法实现
    Method freshMethod = class_getInstanceMethod([self class], @selector(selectedButtonTapped:));
    method_exchangeImplementations(oldMethod, freshMethod);
}

- (void)selectedButtonTapped:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    if (!selectedButton.selected && self.selectedCount >= self.maxSelectCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidReachedMaxSelection:)]) {
            [self.delegate photoBrowserDidReachedMaxSelection:self];
        }
        return;
    }
    [self selectedButtonTapped:sender];
}

- (void)configSelection {
    //计算已选择数量
    for (NSUInteger index = 0; index < [self numberOfPhotos]; index ++) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:)]) {
            BOOL bSelected = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:index];
            if (bSelected) {
                _selectedCount ++;
            }
        }
    }
    
    if (self.assetMediaType == PHAssetMediaTypeUnknown) {
        return;
    }
    Ivar buttonVar = class_getInstanceVariable([MWPhotoBrowser class], [@"_actionButton" UTF8String]);
    if (!buttonVar) {
        return;
    }
    
    if (self.maxSelectCount > 0 && self.maxSelectCount < UINT_MAX) {
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 30, 60, 20)];
        [self.countLabel setTextColor:[UIColor whiteColor]];
        [self.countLabel setFont:[UIFont systemFontOfSize:17]];
        [self.countLabel setTextAlignment:NSTextAlignmentCenter];
        [self.countLabel setText:[NSString stringWithFormat:@"(%lu/%lu)", (unsigned long)self.selectedCount, (unsigned long)self.maxSelectCount]];
        
        UIBarButtonItem *privateButton = [[UIBarButtonItem alloc] initWithCustomView:self.countLabel];
        object_setIvar(self, buttonVar, privateButton);
    }
}

#pragma mark Public methods

#pragma mark Super methods

- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index {
    if (selected && self.selectedCount >= self.maxSelectCount) {
        //limit cell selection
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserDidReachedMaxSelection:)]) {
            [self.delegate photoBrowserDidReachedMaxSelection:self];
        }
        [self reloadData];
        return;
    }
    if (selected) {
        _selectedCount ++;
    } else {
        _selectedCount --;
    }
    [self.countLabel setText:[NSString stringWithFormat:@"(%lu/%lu)", (unsigned long)self.selectedCount, (unsigned long)self.maxSelectCount]];
    [self updateNavigation];
    
    [super setPhotoSelected:selected atIndex:index];
}

- (void)reloadData {
    [super reloadData];
    if (self.startOnGrid) {
        [self hideGrid];
        [self showGrid:NO];
    }
}

- (void)updateNavigation {
    [super updateNavigation];
    // Title
    MWGridViewController *gridController = [self valueForKey:@"_gridController"];
    if (gridController && [gridController isKindOfClass:[MWGridViewController class]] && gridController.selectionMode) {
        self.title = [NSString stringWithFormat:@"(%lu/%lu)", (unsigned long)self.selectedCount, (unsigned long)self.maxSelectCount];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
