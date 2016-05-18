//
//  AESegueModel.m
//  AEBaseProject
//
//  Created by Qian Ye on 16/5/18.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AESegueModel.h"

//H5
NSString *const kAESegueParameterKeyLinkUrl = @"kAESegueParameterKeyLinkUrl";

@interface AESegueModel ()

- (void)fillSegueParamWithData:(NSDictionary *)data;

@end

@implementation AESegueModel

- (instancetype)initWithDestination:(AESegueDestination)destination {
    self = [super init];
    if (self) {
        _destination = destination;
    }
    return self;
}

- (instancetype)initWithDestination:(AESegueDestination)destination paramRawData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _destination = destination;
        [self fillSegueParamWithData:data];
    }
    return self;
}


- (void)fillSegueParamWithData:(NSDictionary *)data {
    switch (self.destination) {
        case AESegueDestinationNone:
            break;
        case AESegueDestinationH5:
        {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *linkUrlString = [data objectForKey:@"linkUrl"];
                if (linkUrlString && [linkUrlString isKindOfClass:[NSString class]]) {
                    _segueParam = [NSDictionary dictionaryWithObject:linkUrlString forKey:kAESegueParameterKeyLinkUrl];
                } else {
                    _destination = AESegueDestinationNone;
                }
            } else {
                _destination = AESegueDestinationNone;
            }
        }
            break;
        default:
            break;
    }
}

@end
