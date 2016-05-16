//
//  AENavigationController.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AENavigationController.h"

@interface AENavigationController ()

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation AENavigationController

-(id)initWithRootViewController:(AEBaseViewController*)_rootViewController
{
    if(self = [super initWithRootViewController:_rootViewController])
    {
        UINavigationBar *navigationBar = [UINavigationBar appearance];
        self.bgColor = [[KTCThemeManager manager] defaultTheme].navibarBGColor;
        [navigationBar aui_setBackgroundColor:self.bgColor];
        CGFloat white = 0.0;
        [self.bgColor getWhite:&white alpha:NULL];
        if (white > 0.8) {
            [navigationBar setBarStyle:UIBarStyleDefault];
        } else {
            [navigationBar setBarStyle:UIBarStyleBlack];
        }
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:18]};
    }
    
    return self;
}

-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - StatusBarTitleColor

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)setNavigationBarBgColor:(UIColor *)color {
    self.bgColor = color;
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar aui_setBackgroundColor:self.bgColor];
}


- (void)setNavigationBarAlpha:(CGFloat)alpha {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar aui_setBackgroundColor:[self.bgColor colorWithAlphaComponent:alpha]];
}


@end
