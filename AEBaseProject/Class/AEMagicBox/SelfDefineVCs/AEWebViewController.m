//
//  AEWebViewController.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/12.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AEWebViewController.h"
#import "AUIKeyboardAdhesiveView.h"
#import "CommonShareViewController.h"
#import "AUIPhotoBrowserViewController.h"

#define UPLOADPHOTO_MAXCOUNT (4)

#define HackCloseWindowFramePrefix (@"HackCloseWindowFramePrefix")

#define Hook_Prefix (@"hook::")
#define Hook_ProductDetail (@"productdetail::")
#define Hook_StoreDetail (@"storeDetail::")
#define Hook_StrategyDetail (@"strategyDetail::")
#define Hook_Home (@"home::")
#define Hook_CouponList (@"couponList::")
#define Hook_Login (@"login::")
#define Hook_Comment (@"evaluate::")
#define Hook_Share (@"share::")
#define Hook_SaveShare (@"saveShare::")

@interface AEWebViewController () <UIWebViewDelegate, AUIKeyboardAdhesiveViewDelegate, AUIPhotoBrowserViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) AUIKeyboardAdhesiveView *keyboardAdhesiveView;

@property (nonatomic, strong) NSDictionary *commentParam;

@property (nonatomic, copy) NSString *callBackJSString;

//photo

@property (nonatomic, strong) NSArray<MWPhoto *> *albumFullScreenPhotos;

@property (nonatomic, strong) NSArray<MWPhoto *> *albumThumbnailPhotos;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedIndexArray;

@property (nonatomic, assign) BOOL hasChangedSelection;

//share

@property (nonatomic, strong) NSDictionary *shareParam;

//other
@property (nonatomic, strong) UIButton *closeButton;

- (void)buildLeftBarButtonsWithCloseHidden:(BOOL)hidden;

- (BOOL)isValidateComment;

- (void)submitCommentsWithUploadLocations:(NSArray *)locationUrls;

- (void)submitCommentSucceed:(NSDictionary *)data;

- (void)submitCommentFailed:(NSError *)error;

- (void)commentWithParams:(NSDictionary *)params;

- (void)didClickedShareButton;

- (void)shareWithParams:(NSDictionary *)params withLocalImage:(BOOL)withLocal;

@end

@implementation AEWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isNavShowType = YES;
        self.backToLink = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add extro info to user-agent
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSString *userAgent = [_webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *extInfo = [NSString stringWithFormat:@"KidsTC/Iphone/%@", appVersion];
    if ([userAgent rangeOfString:extInfo].location == NSNotFound)
    {
        NSString *newUserAgent = [NSString stringWithFormat:@"%@ %@", userAgent, extInfo];
        // Set user agent (the only problem is that we can't modify the User-Agent later in the program)
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
    [self.view addSubview:self.webView];
    self.webView.multipleTouchEnabled = NO;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    if (self.webUrlString)
    {
        [self loadUrl:self.webUrlString];
    }
    
    if (!self.hideShare) {
        [self setupRightBarButton:@"" target:self action:@selector(didClickedShareButton) frontImage:@"share_n" andBackImage:@"share_n"];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self buildLeftBarButtonsWithCloseHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [[GAlertLoadingView sharedAlertLoadingView] hide];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _navigationTitle = title;
}

- (void)dealloc {
    self.webView.delegate = nil;
    if (self.keyboardAdhesiveView) {
        [self.keyboardAdhesiveView destroy];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate

- (void)loadUrl:(NSString *)urlStr
{
    NSString *urlAddress = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *myurl = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:myurl];
    [self.webView loadRequest:requestObj];
}

- (void)setWebUrlString:(NSString *)webUrlString
{
    if (![webUrlString hasPrefix:@"http://"]) {
        webUrlString = [NSString stringWithFormat:@"http://%@", webUrlString];
    }
    if(self.webUrlString != webUrlString)
    {
        _webUrlString = webUrlString;
        if (self.webView)
        {
            [self loadUrl:webUrlString];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL * requestUrl = [request URL];
    NSString *urlString = [requestUrl absoluteString];
    _currentUrlString = urlString;
    self.callBackJSString = nil;
    
    
    //    if ([requestUrl.host hasSuffix:HackCloseWindowFramePrefix]) {
    //        [self closeWebPage];
    //        return NO;
    //    } else if ([urlString hasPrefix:Hook_Prefix]) {
    //        NSString *hookString = [urlString substringFromIndex:[Hook_Prefix length]];
    //        if ([hookString hasPrefix:Hook_Login]) {
    //            [GToolUtil checkLogin:^(NSString *uid) {
    //                [self.webView reload];
    //            } target:self];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_ProductDetail]) {
    //            NSString *jumpString = [hookString substringFromIndex:[Hook_ProductDetail length]];
    //            NSDictionary *params = [GToolUtil parsetUrl:jumpString];
    //            [self pushToServiceDetailWithParams:params];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_StoreDetail]) {
    //            NSString *jumpString = [hookString substringFromIndex:[Hook_StoreDetail length]];
    //            NSDictionary *params = [GToolUtil parsetUrl:jumpString];
    //            [self pushToStoreDetailWithParams:params];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_StrategyDetail]) {
    //            NSString *jumpString = [hookString substringFromIndex:[Hook_StrategyDetail length]];
    //            NSDictionary *params = [GToolUtil parsetUrl:jumpString];
    //            [self pushToStrategyDetailWithParams:params];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_Home]) {
    //            [[KTCTabBarController shareTabBarController] setButtonSelected:0];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_CouponList]) {
    //            NSString *jumpString = [hookString substringFromIndex:[Hook_CouponList length]];
    //            NSDictionary *params = [GToolUtil parsetUrl:jumpString];
    //            [self pushToCouponListWithParams:params];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_Comment]) {
    //            NSString *paramString = [hookString substringFromIndex:[Hook_Comment length]];
    //            NSDictionary *params = [GToolUtil parsetUrl:paramString];
    //            [self commentWithParams:params];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_Share]) {
    //            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    //            NSArray *paramsArray = [hookString componentsSeparatedByString:@";"];
    //            for (NSString *string in paramsArray) {
    //                NSRange titleRange = [string rangeOfString:@"share::title="];
    //                NSRange descRange = [string rangeOfString:@"desc="];
    //                NSRange picRange = [string rangeOfString:@"pic="];
    //                NSRange urlRange = [string rangeOfString:@"url="];
    //                if (titleRange.location != NSNotFound) {
    //                    NSString *title = [string substringFromIndex:titleRange.length];
    //                    title = [title URLDecodedString];
    //                    [tempDic setObject:title forKey:@"title"];
    //                    continue;
    //                }
    //                if (descRange.location != NSNotFound) {
    //                    NSString *desc = [string substringFromIndex:descRange.length];
    //                    desc = [desc URLDecodedString];
    //                    [tempDic setObject:desc forKey:@"desc"];
    //                    continue;
    //                }
    //                if (picRange.location != NSNotFound) {
    //                    NSString *pic = [string substringFromIndex:picRange.length];
    //                    [tempDic setObject:pic forKey:@"pic"];
    //                    continue;
    //                }
    //                if (urlRange.location != NSNotFound) {
    //                    NSString *url = [string substringFromIndex:urlRange.length];
    //                    [tempDic setObject:url forKey:@"url"];
    //                    NSDictionary *urlParamsDic = [GToolUtil parsetUrl:url];
    //                    if ([urlParamsDic objectForKey:@"id"]) {
    //                        NSString *identifier = [NSString stringWithFormat:@"%@", [urlParamsDic objectForKey:@"id"]];
    //                        [tempDic setObject:identifier forKey:@"id"];
    //
    //                    }
    //                    continue;
    //                }
    //            }
    //            if ([tempDic count] == 0) {
    //                return YES;
    //            }
    //            [self shareWithParams:[NSDictionary dictionaryWithDictionary:tempDic] withLocalImage:NO];
    //            return NO;
    //        } else if ([hookString hasPrefix:Hook_SaveShare]) {
    //            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    //            NSArray *paramsArray = [hookString componentsSeparatedByString:@";"];
    //            for (NSString *string in paramsArray) {
    //                NSRange titleRange = [string rangeOfString:@"saveShare::title="];
    //                NSRange descRange = [string rangeOfString:@"desc="];
    //                NSRange picRange = [string rangeOfString:@"pic="];
    //                NSRange urlRange = [string rangeOfString:@"url="];
    //                if (titleRange.location != NSNotFound) {
    //                    NSString *title = [string substringFromIndex:titleRange.length];
    //                    title = [title URLDecodedString];
    //                    [tempDic setObject:title forKey:@"title"];
    //                    continue;
    //                }
    //                if (descRange.location != NSNotFound) {
    //                    NSString *desc = [string substringFromIndex:descRange.length];
    //                    desc = [desc URLDecodedString];
    //                    [tempDic setObject:desc forKey:@"desc"];
    //                    continue;
    //                }
    //                if (picRange.location != NSNotFound) {
    //                    NSString *pic = [string substringFromIndex:picRange.length];
    //                    [tempDic setObject:pic forKey:@"pic"];
    //                    continue;
    //                }
    //                if (urlRange.location != NSNotFound) {
    //                    NSString *url = [string substringFromIndex:urlRange.length];
    //                    [tempDic setObject:url forKey:@"url"];
    //                    NSDictionary *urlParamsDic = [GToolUtil parsetUrl:url];
    //                    if ([urlParamsDic objectForKey:@"id"]) {
    //                        NSString *identifier = [NSString stringWithFormat:@"%@", [urlParamsDic objectForKey:@"id"]];
    //                        [tempDic setObject:identifier forKey:@"id"];
    //
    //                    }
    //                    continue;
    //                }
    //            }
    //            if ([tempDic count] == 0) {
    //                return YES;
    //            }
    //            self.shareParam = [NSDictionary dictionaryWithDictionary:tempDic];
    //            return NO;
    //        }
    //    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
        [self.delegate webViewControllerDidStartLoad:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title)
    {
        self.navigationItem.title = title;
        _navigationTitle = title;
    } else {
        self.navigationItem.title = @"童成网";
        _navigationTitle = title;
    }
}

- (void)webView:(UIWebView *)webView_ didFailLoadWithError:(NSError *)error
{
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
            UIImage *placeHolder = [[UIImage alloc] init];
            [tempThumnailImageArray addObject:placeHolder];
            [thumbPhoto loadImageWithResult:^(UIImage *image, CGFloat progress, NSError *error) {
                if (image) {
                    [tempThumnailImageArray replaceObjectAtIndex:index withObject:image];
                    [_keyboardAdhesiveView setUploadImages:[NSArray arrayWithArray:tempThumnailImageArray]];
                }
            }];
        }
        [_keyboardAdhesiveView setUploadImages:[NSArray arrayWithArray:tempThumnailImageArray]];
    }
}

#pragma mark AUIKeyboardAdhesiveViewDelegate

- (void)keyboardAdhesiveView:(AUIKeyboardAdhesiveView *)view didClickedExtensionFunctionButtonWithType:(AUIKeyboardAdhesiveViewExtensionFunctionType)type {
    if (type == AUIKeyboardAdhesiveViewExtensionFunctionTypeImageUpload) {
        self.hasChangedSelection = NO;
        AUIPhotoBrowserViewController *photoBrowser = [AUIPhotoBrowserViewController browserWithAlbumMediaType:PHAssetMediaTypeImage needAutoLoad:YES showGrid:YES];
        photoBrowser.delegate = self;
        photoBrowser.startOnGrid = YES;
        [photoBrowser setMaxSelectCount:UPLOADPHOTO_MAXCOUNT];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
        [navi.navigationBar aui_setBackgroundColor:[UIColor blackColor]];
        [self presentViewController:navi animated:YES completion:nil];
    }
}

- (void)didClickedSendButtonOnKeyboardAdhesiveView:(AUIKeyboardAdhesiveView *)view {
    //    if (!self.commentParam) {
    //        return;
    //    }
    //    if (![self isValidateComment]) {
    //        return;
    //    }
    //    [[GAlertLoadingView sharedAlertLoadingView] show];
    //    if (self.photoDictionary) {
    //        __weak KTCWebViewController *weakSelf = self;
    //        [weakSelf getNeedUploadPhotosArray:^(NSArray *photosArray) {
    //            [[KTCImageUploader sharedInstance] startUploadWithImagesArray:photosArray splitCount:2 withSucceed:^(NSArray *locateUrlStrings) {
    //                [weakSelf submitCommentsWithUploadLocations:locateUrlStrings];
    //            } failure:^(NSError *error) {
    //                [[GAlertLoadingView sharedAlertLoadingView] hide];
    //                if (error.userInfo) {
    //                    NSString *errMsg = [error.userInfo objectForKey:@"data"];
    //                    if ([errMsg isKindOfClass:[NSString class]] && [errMsg length] > 0) {
    //
    //                        [[iToast makeText:errMsg] show];
    //                    } else {
    //                        [[iToast makeText:@"照片上传失败，请重新提交"] show];
    //                    }
    //                } else {
    //                    [[iToast makeText:@"照片上传失败，请重新提交"] show];
    //                }
    //            }];
    //        }];
    //    } else {
    //        [self submitCommentsWithUploadLocations:nil];
    //    }
}

- (void)keyboardAdhesiveView:(AUIKeyboardAdhesiveView *)view didClickedUploadImageAtIndex:(NSUInteger)index {
    self.hasChangedSelection = NO;
    AUIPhotoBrowserViewController *photoBrowser = [AUIPhotoBrowserViewController browserWithAlbumMediaType:PHAssetMediaTypeImage needAutoLoad:NO showGrid:NO];
    
    photoBrowser.delegate = self;
    [photoBrowser setCurrentPhotoIndex:[[self.selectedIndexArray objectAtIndex:index] unsignedIntegerValue]];
    [photoBrowser setMaxSelectCount:UPLOADPHOTO_MAXCOUNT];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    [navi.navigationBar aui_setBackgroundColor:[UIColor blackColor]];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark Private methods

- (void)buildLeftBarButtonsWithCloseHidden:(BOOL)hidden {
    CGFloat buttonWidth = 28;
    CGFloat buttonHeight = 28;
    CGFloat buttonGap = 15;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(-15, 0, buttonWidth * 2 + buttonGap, buttonHeight)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat xPosition = 0;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(xPosition, 0, buttonWidth, buttonHeight)];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setImage:[UIImage imageNamed:@"navigation_back_n"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"navigation_back_n"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(goBackController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [bgView addSubview:backButton];
    
    xPosition += buttonWidth + buttonGap;
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setFrame:CGRectMake(xPosition, 0, buttonWidth, buttonHeight)];
    [self.closeButton setBackgroundColor:[UIColor clearColor]];
    [self.closeButton setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateNormal];
    [self.closeButton setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateHighlighted];
    [self.closeButton addTarget:self action:@selector(closeWebPage) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.closeButton];
    [self.closeButton setHidden:YES];
    
    UIBarButtonItem *lItem = [[UIBarButtonItem alloc] initWithCustomView:bgView];
    self.navigationItem.leftBarButtonItem = lItem;
}

- (IBAction)didClickedBackToTopButton:(id)sender {
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, self.webView.scrollView.frame.size.width, self.webView.scrollView.frame.size.height) animated:YES];
}


#pragma mark Jump Methods


#pragma mark Comment

- (void)commentWithParams:(NSDictionary *)params {
    self.commentParam = params;
    if (!params) {
        return;
    }
    if (!self.keyboardAdhesiveView) {
        AUIKeyboardAdhesiveViewExtensionFunction *photoFunc = [AUIKeyboardAdhesiveViewExtensionFunction funtionWithType:AUIKeyboardAdhesiveViewExtensionFunctionTypeImageUpload];
        self.keyboardAdhesiveView = [[AUIKeyboardAdhesiveView alloc] initWithAvailableFuntions:[NSArray arrayWithObject:photoFunc]];
        [self.keyboardAdhesiveView.headerView setBackgroundColor:[[KTCThemeManager manager] defaultTheme].globalThemeColor];
        [self.keyboardAdhesiveView setTextLimitLength:100];
        [self.keyboardAdhesiveView setUploadImageLimitCount:UPLOADPHOTO_MAXCOUNT];
        self.keyboardAdhesiveView.delegate = self;
    }
    //    [GToolUtil checkLogin:^(NSString *uid) {
    //        [self.keyboardAdhesiveView expand];
    //        self.callBackJSString = [params objectForKey:@"callback"];
    //    } target:self];
}

#define MIN_COMMENTLENGTH (1)

- (BOOL)isValidateComment {
    NSString *commentText = self.keyboardAdhesiveView.text;
    commentText = [commentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([commentText length] < MIN_COMMENTLENGTH) {
        [[iToast makeText:@"请至少输入1个字"] show];
        return NO;
    }
    
    return YES;
}


- (void)submitCommentsWithUploadLocations:(NSArray *)locationUrls {
    //    KTCCommentObject *object = [[KTCCommentObject alloc] init];
    //    if ([self.commentParam objectForKey:@"relationSysNo"]) {
    //        object.identifier = [NSString stringWithFormat:@"%@", [self.commentParam objectForKey:@"relationSysNo"]];
    //    }
    //    object.relationType = (CommentRelationType)[[self.commentParam objectForKey:@"relationType"] integerValue];
    //    object.isAnonymous = NO;
    //    object.isComment = [[self.commentParam objectForKey:@"isComment"] boolValue];
    //    if ([self.commentParam objectForKey:@"replyId"]) {
    //        object.commentIdentifier = [NSString stringWithFormat:@"%@", [self.commentParam objectForKey:@"replyId"]];
    //    }
    //    object.content = self.keyboardAdhesiveView.text;
    //    object.uploadImageStrings = locationUrls;
    //
    //    if (!self.commentManager) {
    //        self.commentManager = [[KTCCommentManager alloc] init];
    //    }
    //    __weak KTCWebViewController *weakSelf = self;
    //    [weakSelf.commentManager addCommentWithObject:object succeed:^(NSDictionary *data) {
    //        [[GAlertLoadingView sharedAlertLoadingView] hide];
    //        [weakSelf submitCommentSucceed:data];
    //    } failure:^(NSError *error) {
    //        [[GAlertLoadingView sharedAlertLoadingView] hide];
    //        [weakSelf submitCommentFailed:error];
    //    }];
}

- (void)submitCommentSucceed:(NSDictionary *)data {
    [self.keyboardAdhesiveView shrink];
    if ([self.callBackJSString length] > 0) {
        [self.webView stringByEvaluatingJavaScriptFromString:self.callBackJSString];
    }
    self.callBackJSString = nil;
}

- (void)submitCommentFailed:(NSError *)error {
    NSString *errMsg = @"提交评论失败，请重新提交。";
    NSString *remoteErrMsg = [error.userInfo objectForKey:@"data"];
    if ([remoteErrMsg isKindOfClass:[NSString class]] && [remoteErrMsg length] > 0) {
        errMsg = remoteErrMsg;
    }
    [[iToast makeText:errMsg] show];
}

#pragma mark Share

- (void)didClickedShareButton {
    if (self.shareParam) {
        [self shareWithParams:self.shareParam withLocalImage:NO];
        return;
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:_navigationTitle, @"title", @"与您分享", @"desc", self.currentUrlString, @"url", nil];
    [self shareWithParams:param withLocalImage:YES];
}

- (void)shareWithParams:(NSDictionary *)params withLocalImage:(BOOL)withLocal {
    NSString *title = [params objectForKey:@"title"];
    NSString *desc = [params objectForKey:@"desc"];
    NSString *thumbUrlString = [params objectForKey:@"pic"];
    NSString *linkUrlString = [params objectForKey:@"url"];
    NSString *identifier = [params objectForKey:@"id"];
    
    CommonShareObject *shareObject = nil;
    if (withLocal) {
        shareObject = [CommonShareObject shareObjectWithTitle:title description:desc thumbImage:[UIImage imageNamed:@"defaultShareImage"] urlString:linkUrlString];
    } else {
        shareObject = [CommonShareObject shareObjectWithTitle:title description:desc thumbImageUrl:[NSURL URLWithString:thumbUrlString] urlString:linkUrlString];
    }
    shareObject.identifier = identifier;
    shareObject.followingContent = @"【童成网】";
    CommonShareViewController *controller = [CommonShareViewController instanceWithShareObject:shareObject sourceType:KTCShareServiceTypeNews];
    
    [self presentViewController:controller animated:YES completion:nil] ;
}

#pragma mark Public Methods

- (void)closeWebPage
{
    self.webUrlString = nil;
    _currentUrlString = nil;
    [super goBackController:nil];
}

#pragma mark Super Methods

- (void)goBackController:(id)sender
{
    if (!self.isRootVC) {
        [self.closeButton setHidden:![self.webView canGoBack]];
    }
    
    if([self.webView canGoBack])
    {
        [self.webView goBack];
    } else if (self.isRootVC) {
        //只有一个webViewController
        [[AETabBarController sharedTabBarController] setSelectedIndex:0];
    } else {
        [super goBackController:sender];
        self.webUrlString = nil;
    }
}

@end
