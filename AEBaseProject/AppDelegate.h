//
//  AppDelegate.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/3.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AETabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIWindow *welcomeWindow;

@property (nonatomic, strong) AETabBarController *tabbarController;


@end

