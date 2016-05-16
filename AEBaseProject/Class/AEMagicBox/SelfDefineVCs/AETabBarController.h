//
//  AETabBarController.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AETabBarController : UITabBarController

@property (nonatomic, readonly) NSUInteger tabCount;

+ (AETabBarController *)sharedTabBarController;

- (UIViewController *)rootViewControllerAtIndex:(NSUInteger)index;

- (void)createViewControllers;

- (void)allPopToRoot;

- (void)makeTabBarHidden:(BOOL)hidden;

- (void)setBadge:(NSString *)badgeString forTabIndex:(NSUInteger)index;

- (void)resetTheme:(AUITheme *)theme;

@end
