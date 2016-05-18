//
//  AESegueModel.h
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/18.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AESegueDestinationNone = 0, //无跳转
    AESegueDestinationH5 = 1 //H5
}AESegueDestination;

//H5
extern NSString *const kAESegueParameterKeyLinkUrl;

@interface AESegueModel : NSObject

@property (nonatomic, readonly) AESegueDestination destination;

@property (nonatomic, strong, readonly) NSDictionary *segueParam;

- (instancetype)initWithDestination:(AESegueDestination)destination;

- (instancetype)initWithDestination:(AESegueDestination)destination paramRawData:(NSDictionary *)data;

@end
