//
//  AENavigationController.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AENavigationController : UINavigationController <UINavigationControllerDelegate>

- (void)setNavigationBarBgColor:(UIColor *)color;

- (void)setNavigationBarAlpha:(CGFloat)alpha;

@end
