//
//  AEBaseViewController.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GConnectUselessView.h"

@interface AEBaseViewController : UIViewController<GConnectUselessViewDelegate> {
    UITapGestureRecognizer *_tapGesture;
    NSString *_navigationTitle;
    NSString *_pageIdentifier;
    BOOL showFirstTime;
}

@property (nonatomic, copy) NSString *pageIdentifier;

@property (strong, nonatomic) GConnectUselessView *statusView;
@property BOOL isNavShowType;
@property BOOL isConnectFailed;
@property (nonatomic, assign) BOOL bTapToEndEditing;
@property (nonatomic, readonly) CGFloat keyboardHeight;

- (void)setupBackBarButton;
- (void)setupLeftBarButton;
- (void)setupLeftBarButtonWithFrontImage:(NSString*)frontImgName andBackImage:(NSString *)backImgName;
- (void)setupRightBarButton:(NSString*)title target:(id)object action:(SEL)selector frontImage:(NSString*)frontImgName andBackImage:(NSString *)backImgName;
- (void)setRightBarButtonTitle:(NSString*)title frontImage:(NSString*)frontImgName andBackImage:(NSString *)backImgName;
- (void)goBackController:(id)sender;

- (void)showConnectError:(BOOL)show;
- (void)showConnectError:(BOOL)show opaqueBG:(BOOL)opaque;
- (void)reloadNetworkData;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillDisappear:(NSNotification *)notification;

@end
