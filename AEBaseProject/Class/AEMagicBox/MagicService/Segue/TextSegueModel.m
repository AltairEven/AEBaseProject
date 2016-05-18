//
//  TextSegueModel.m
//  KidsTC
//
//  Created by Altair on 1/16/16.
//  Copyright © 2016 KidsTC. All rights reserved.
//

#import "TextSegueModel.h"

@implementation TextSegueModel

- (instancetype)initWithLinkParam:(NSDictionary *)param promotionWords:(NSString *)words {
    if (!param || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (![words isKindOfClass:[NSString class]] || [words length] == 0) {
        return nil;
    }
    self = [super init];
    if (self) {
        _linkColor = [UIColor colorWithRGBString:[param objectForKey:@"color"]];
        if (!_linkColor) {
            _linkColor = [UIColor blueColor];
        }
        _promotionWords = words;
        _linkWords = [param objectForKey:@"linkKey"];
        _linkRangeStrings = [self.promotionWords rangeStringsOfSubString:self.linkWords];
        AESegueDestination destination = (AESegueDestination)[[param objectForKey:@"linkType"] integerValue];
        if (destination != AESegueDestinationNone) {
            _segueModel = [[AESegueModel alloc] initWithDestination:destination paramRawData:[param objectForKey:@"params"]];
        }
    }
    return self;
}

@end
