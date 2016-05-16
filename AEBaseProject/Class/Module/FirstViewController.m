//
//  FirstViewController.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/5.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "FirstViewController.h"
#import "AUIImageGridView.h"
#import "AUIPhotoBrowserViewController.h"
#import <objc/runtime.h>

@interface FirstViewController () <AUIImageGridViewDelegate, AUIPhotoBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet AUIImageGridView *imageGridView;

@property (nonatomic, strong) NSArray<MWPhoto *> *albumFullScreenPhotos;

@property (nonatomic, strong) NSArray<MWPhoto *> *albumThumbnailPhotos;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedIndexArray;

@property (nonatomic, assign) BOOL hasChangedSelection;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageGridView.delegate = self;
    [self.imageGridView setMaxLimit:10];
    [self.imageGridView setShowAddButton:YES];
    [self.imageGridView resetBeforeLayoutWithWidth:SCREEN_WIDTH - 20];
}

#pragma mark AUIImageGridViewDelegate

- (void)didClickedAddButtonOnImageGridView:(AUIImageGridView *)view {
    self.hasChangedSelection = NO;
    AUIPhotoBrowserViewController *photoBrowser = [AUIPhotoBrowserViewController browserWithAlbumMediaType:PHAssetMediaTypeImage needAutoLoad:YES showGrid:YES];
    photoBrowser.delegate = self;
    photoBrowser.startOnGrid = YES;
    [photoBrowser setMaxSelectCount:10];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    [navi.navigationBar aui_setBackgroundColor:[UIColor blackColor]];
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)imageGridView:(AUIImageGridView *)view didClickedImageAtIndex:(NSUInteger)index {
    self.hasChangedSelection = NO;
    AUIPhotoBrowserViewController *photoBrowser = [AUIPhotoBrowserViewController browserWithAlbumMediaType:PHAssetMediaTypeImage needAutoLoad:NO showGrid:NO];
    
    photoBrowser.delegate = self;
    [photoBrowser setCurrentPhotoIndex:[[self.selectedIndexArray objectAtIndex:index] unsignedIntegerValue]];
    [photoBrowser setMaxSelectCount:10];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    [navi.navigationBar aui_setBackgroundColor:[UIColor blackColor]];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark AUIPhotoBrowserViewControllerDelegate

- (BOOL)photoBrowser:(AUIPhotoBrowserViewController *)photoBrowse didFinishedFetchingAlbumMediaWithType:(PHAssetMediaType)type fullScreenPhotos:(NSArray<MWPhoto *> *)fullScreenPhotos thumbnailPhotos:(NSArray<MWPhoto *> *)thumbnailPhotos {
    _albumFullScreenPhotos = [NSArray arrayWithArray:fullScreenPhotos];
    _albumThumbnailPhotos = [NSArray arrayWithArray:thumbnailPhotos];
    return YES;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    NSUInteger count = 0;
    count = [self.albumFullScreenPhotos count];
    return count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo = nil;
    photo = [self.albumFullScreenPhotos objectAtIndex:index];
    return photo;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo = nil;
    photo = [self.albumThumbnailPhotos objectAtIndex:index];
    return photo;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    BOOL isSelected = NO;
    if (self.selectedIndexArray && [self.selectedIndexArray indexOfObject:[NSNumber numberWithUnsignedInteger:index]] != NSNotFound) {
        isSelected = YES;
    }
    return isSelected;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    if (!self.selectedIndexArray) {
        self.selectedIndexArray = [[NSMutableArray alloc] init];
    }
    if (selected) {
        [self.selectedIndexArray addObject:[NSNumber numberWithUnsignedInteger:index]];
    } else {
        [self.selectedIndexArray removeObject:[NSNumber numberWithUnsignedInteger:index]];
    }
    self.hasChangedSelection = YES;
}

- (void)photoBrowserWillDisappear:(MWPhotoBrowser *)photoBrowser {
    if (self.hasChangedSelection) {
        NSMutableArray *tempThumnailImageArray = [[NSMutableArray alloc] init];
        for (NSUInteger index = 0; index < [self.selectedIndexArray count]; index ++) {
            NSNumber *photoIndex = [self.selectedIndexArray objectAtIndex:index];
            MWPhoto *thumbPhoto = [self.albumThumbnailPhotos objectAtIndex:[photoIndex unsignedIntegerValue]];
            thumbPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://cc.cocimg.com/api/uploads/20160508/1462691272231375.jpg"]];
            thumbPhoto.resourceType = MWPhotoResourceTypeUrl;
            UIImage *placeHolder = [[UIImage alloc] init];
            [tempThumnailImageArray addObject:placeHolder];
            [thumbPhoto loadImageWithResult:^(UIImage *image, CGFloat progress, NSError *error) {
                if (image) {
                    [tempThumnailImageArray replaceObjectAtIndex:index withObject:image];
                    [_imageGridView setImagesArray:[NSArray arrayWithArray:tempThumnailImageArray]];
                }
            }];
        }
        [_imageGridView setImagesArray:[NSArray arrayWithArray:tempThumnailImageArray]];
    }
}

#pragma mark Private methods


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
