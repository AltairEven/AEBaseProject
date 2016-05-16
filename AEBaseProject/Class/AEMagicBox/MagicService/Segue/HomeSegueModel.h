//
//  HomeSegueModel.h
//  KidsTC
//
//  Created by 钱烨 on 10/10/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HomeSegueDestinationNone = 0, //无跳转
    HomeSegueDestinationH5 = 1 //H5
}HomeSegueDestination;

//H5
extern NSString *const kHomeSegueParameterKeyLinkUrl;

@interface HomeSegueModel : NSObject

@property (nonatomic, readonly) HomeSegueDestination destination;

@property (nonatomic, strong, readonly) NSDictionary *segueParam;

- (instancetype)initWithDestination:(HomeSegueDestination)destination;

- (instancetype)initWithDestination:(HomeSegueDestination)destination paramRawData:(NSDictionary *)data;

@end
