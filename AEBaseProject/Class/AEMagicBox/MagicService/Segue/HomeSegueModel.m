//
//  HomeSegueModel.m
//  KidsTC
//
//  Created by 钱烨 on 10/10/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "HomeSegueModel.h"

//H5
NSString *const kHomeSegueParameterKeyLinkUrl = @"kHomeSegueParameterKeyLinkUrl";

@interface HomeSegueModel ()

- (void)fillSegueParamWithData:(NSDictionary *)data;

@end

@implementation HomeSegueModel

- (instancetype)initWithDestination:(HomeSegueDestination)destination {
    self = [super init];
    if (self) {
        _destination = destination;
    }
    return self;
}

- (instancetype)initWithDestination:(HomeSegueDestination)destination paramRawData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _destination = destination;
        [self fillSegueParamWithData:data];
    }
    return self;
}


- (void)fillSegueParamWithData:(NSDictionary *)data {
    switch (self.destination) {
        case HomeSegueDestinationNone:
            break;
        case HomeSegueDestinationH5:
        {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *linkUrlString = [data objectForKey:@"linkUrl"];
                if (linkUrlString && [linkUrlString isKindOfClass:[NSString class]]) {
                    _segueParam = [NSDictionary dictionaryWithObject:linkUrlString forKey:kHomeSegueParameterKeyLinkUrl];
                } else {
                    _destination = HomeSegueDestinationNone;
                }
            } else {
                _destination = HomeSegueDestinationNone;
            }
        }
            break;
        default:
            break;
    }
}

@end
