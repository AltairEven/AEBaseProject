//
//  CommonLoginViewController.h
//  PingYu
//
//  Created by Qian Ye on 16/3/29.
//  Copyright © 2016年 Alisports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThirdPartyLoginService.h"

@interface CommonLoginViewController : UIViewController

+ (instancetype)instanceWithLoginSucceed:(void(^)())succeed failure:(void(^)())failure;


@end
