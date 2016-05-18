//
//  AESegueMaster.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AESegueModel.h"

#define NotificationSegueTag (100001)

@interface AESegueMaster : NSObject

+ (UIViewController *)makeSegueWithModel:(AESegueModel *)model fromController:(UIViewController *)fromVC;

@end
