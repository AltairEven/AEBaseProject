//
//  AETabBarController.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AETabBarController.h"
#import "AdditionalTabBarItemManager.h"
#import "FirstViewController.h"

static AETabBarController* _sharedTabBarController = nil;

@interface AETabBarController () <UITabBarControllerDelegate>

- (void)didReceivedThemeChangedNotification:(NSNotification *)notify;

@end

@implementation AETabBarController

+ (AETabBarController*)sharedTabBarController
{
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        _sharedTabBarController = [[AETabBarController alloc] init];
        [_sharedTabBarController.tabBar setBarTintColor:[[KTCThemeManager manager] defaultTheme].tabbarBGColor];
    });
    
    return _sharedTabBarController;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)createViewControllers
{
    self.delegate = self;
    
    AUITheme *theme = [[AdditionalTabBarItemManager sharedManager] themeWithAdditionalTabBarItemInfo:[[KTCThemeManager manager] defaultTheme]];
    NSArray *tabBarItemElements = [theme tabbarItemElements];
    _tabCount = [tabBarItemElements count];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (AUITabbarItemElement *element in tabBarItemElements) {
        UIViewController *viewController = nil;
        switch (element.type) {
            case AUITabbarItemTypeHome:
            {
                viewController = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
            }
                break;
            case AUITabbarItemTypeNews:
            {
                //                viewController = [[CertificationViewController alloc] initWithNibName:@"CertificationViewController" bundle:nil];
                
                viewController = [[AEBaseViewController alloc] init];
            }
                break;
            case AUITabbarItemTypeStrategy:
            {
                //                viewController = [[DiscoveryViewController alloc] initWithNibName:@"DiscoveryViewController" bundle:nil];
                
                viewController = [[AEBaseViewController alloc] init];
            }
                break;
            case AUITabbarItemTypeUserCenter:
            {
                //                viewController = [[MeViewController alloc] initWithNibName:@"MeViewController" bundle:nil];
                
                viewController = [[AEBaseViewController alloc] init];
            }
                break;
            case AUITabbarItemTypeAdditional:
            {
                //                viewController = [[CompetitionViewController alloc] initWithNibName:@"CompetitionViewController" bundle:nil];
                
                viewController = [[AEBaseViewController alloc] init];
            }
                break;
            default:
                break;
        }
        if (viewController) {
            UINavigationController *naviController = [[AENavigationController alloc] initWithRootViewController:viewController];
            naviController.tabBarItem.title = element.tabbarItemTitle;
            if (element.tabbarTitleColor_Normal) {
                [naviController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:element.tabbarTitleColor_Normal forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
            }
            if (element.tabbarTitleColor_Highlight) {
                [naviController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:element.tabbarTitleColor_Highlight forKey:NSForegroundColorAttributeName] forState:UIControlStateHighlighted];
            }
            naviController.tabBarItem.image = [element.tabbarItemImage_Normal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            naviController.tabBarItem.selectedImage = [element.tabbarItemImage_Highlight imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [tempArray addObject:naviController];
        }
    }
    
    
    [self setViewControllers:[NSArray arrayWithArray:tempArray] animated: YES];
    
    self.selectedIndex = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedThemeChangedNotification:) name:kThemeDidChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeDidChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController respondsToSelector:@selector(popToRootViewControllerAnimated:)])
    {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
    
    for (NSUInteger index = 0; index < self.tabCount; index ++) {
        if (viewController == [self.viewControllers objectAtIndex:index]) {
            [self setBadge:nil forTabIndex:index];
            if (self.selectedIndex == index) {
                //                UIViewController *controller = [(UINavigationController *)viewController topViewController];
                //                if ([controller isKindOfClass:[KTCWebViewController class]]) {
                //                    [[(KTCWebViewController *)controller webView] reload];
                //                }
            }
            self.selectedIndex = index;
            break;
        }
    }
    //    if (_selectTabBarButtonIndex == 1 || _selectTabBarButtonIndex == 2 || _selectTabBarButtonIndex == 3) {
    //        [GToolUtil checkLogin:nil target:self];
    //    }
    
    return YES;
}

- (UIViewController *)rootViewControllerAtIndex:(NSUInteger)index {
    if (index < [self.viewControllers count])
    {
        UINavigationController *naviController = [self.viewControllers objectAtIndex:index];
        if ([naviController isKindOfClass:[UINavigationController class]]) {
            return [[naviController viewControllers] objectAtIndex:0];
        }
    }
    return nil;
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    if (selectedIndex < [self.viewControllers count])
    {
        UIViewController *willSelectedController = [self.viewControllers objectAtIndex:selectedIndex];
        if ([willSelectedController respondsToSelector:@selector(popToRootViewControllerAnimated:)])
        {
            [(UINavigationController *)willSelectedController popToRootViewControllerAnimated:NO];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
}

- (void)allPopToRoot
{
    NSArray *naviControllers = [self viewControllers];
    for (UINavigationController *navi in naviControllers) {
        [navi popToRootViewControllerAnimated:NO];
    }
}

- (void)makeTabBarHidden:(BOOL)hidden
{
    if ( [self.view.subviews count] < 2 )
        return;
    
    UIView *contentView;
    
    if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.view.subviews objectAtIndex:1];
    else
        contentView = [self.view.subviews objectAtIndex:0];
    
    if ( hidden ){
        contentView.frame = self.view.bounds;
    }
    else{
        contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                       self.view.bounds.origin.y,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - self.tabBar.frame.size.height);
    }
    
    self.tabBar.hidden = hidden;
}

- (void)setBadge:(NSString *)badgeString forTabIndex:(NSUInteger)index {
    if (self.selectedIndex == index) {
        return;
    }
    [self.tabBar setBadgeWithValue:badgeString atIndex:(int)index];
}

- (void)didReceivedThemeChangedNotification:(NSNotification *)notify {
    if (!notify || ![notify.name isEqualToString:kThemeDidChangedNotification]) {
        return;
    }
    [self resetTheme:notify.object];
}

- (void)resetTheme:(AUITheme *)theme {
    if (!theme || ![theme isKindOfClass:[AUITheme class]]) {
        return;
    }
    [self.tabBar setBarTintColor:theme.tabbarBGColor];
    
    NSUInteger themeTabCount = [theme.tabbarItemElements count];
    if (self.tabCount != themeTabCount) {
        return;
    }
    
    for (NSUInteger index = 0; index < [self.viewControllers count]; index ++) {
        UINavigationController *naviController = [self.viewControllers objectAtIndex:index];
        AUITabbarItemElement *element = [theme.tabbarItemElements objectAtIndex:index];
        naviController.tabBarItem.title = element.tabbarItemTitle;
        if (element.tabbarTitleColor_Normal) {
            [naviController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:element.tabbarTitleColor_Normal forKey:NSForegroundColorAttributeName] forState:UIControlStateNormal];
        }
        if (element.tabbarTitleColor_Highlight) {
            [naviController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:element.tabbarTitleColor_Highlight forKey:NSForegroundColorAttributeName] forState:UIControlStateHighlighted];
        }
        naviController.tabBarItem.image = [element.tabbarItemImage_Normal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        naviController.tabBarItem.selectedImage = [element.tabbarItemImage_Highlight imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

@end
