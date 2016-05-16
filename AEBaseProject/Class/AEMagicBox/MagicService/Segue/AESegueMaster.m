//
//  AESegueMaster.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AESegueMaster.h"

@implementation AESegueMaster

+ (UIViewController *)makeSegueWithModel:(HomeSegueModel *)model fromController:(UIViewController *)fromVC {
    if (!model || ![model isKindOfClass:[HomeSegueModel class]]) {
        return nil;
    }
    if (!fromVC || ![fromVC isKindOfClass:[UIViewController class]] || !fromVC.navigationController) {
        return nil;
    }
    UIViewController *toController = nil;
    switch (model.destination) {
        case HomeSegueDestinationH5:
        {
            AEWebViewController *controller = [[AEWebViewController alloc] init];
            [controller setWebUrlString:[model.segueParam objectForKey:kHomeSegueParameterKeyLinkUrl]];
            [controller setHidesBottomBarWhenPushed:YES];
            toController = controller;
        }
            break;
        default:
            break;
    }
    if (toController) {
        [fromVC.navigationController pushViewController:toController animated:YES];
    }
    //Statistics
    
    return toController;
}

@end
