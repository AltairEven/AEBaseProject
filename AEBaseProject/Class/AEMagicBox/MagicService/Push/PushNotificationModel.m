//
//  PushNotificationModel.m
//  KidsTC
//
//  Created by Altair on 11/30/15.
//  Copyright © 2015 KidsTC. All rights reserved.
//

#import "PushNotificationModel.h"

@implementation PushNotificationModel

- (instancetype)initWithRawData:(NSDictionary *)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.identifier = [NSString stringWithFormat:@"%@", [data objectForKey:@"sysNo"]];
        self.title = [data objectForKey:@"title"];
        self.content = [data objectForKey:@"content"];
        self.createTimeDescription = [data objectForKey:@"createTime"];
        self.updateTimeDescription = [data objectForKey:@"updateTime"];
        self.status = (PushNotificationStatus)[[data objectForKey:@"status"] integerValue];
        NSDictionary *dic = [data objectForKey:@"dic"];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            AESegueDestination dest = (AESegueDestination)[[dic objectForKey:@"linkType"] integerValue];
            if (dest != AESegueDestinationNone) {
                NSString *paramString = [dic objectForKey:@"params"];
                NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:paramData options:NSJSONReadingAllowFragments error:nil];
                self.segueModel = [[AESegueModel alloc] initWithDestination:dest paramRawData:paramDic];
            }
        }
    }
    return self;
}

- (instancetype)initWithRemoteNotificationData:(NSDictionary *)data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if (self) {
        NSString *contentString = [data objectForKey:@"CustomDicStr"];
        if (!contentString || ![contentString isKindOfClass:[NSString class]]) {
            return nil;
        }
        NSData *paramData = [contentString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *content = [NSJSONSerialization JSONObjectWithData:paramData options:NSJSONReadingAllowFragments error:nil];
        
        self.createTimeDescription = [content objectForKey:@"pushtime"];
        AESegueDestination dest = (AESegueDestination)[[content objectForKey:@"linkType"] integerValue];
        if (dest != AESegueDestinationNone) {
            NSString *paramString = [content objectForKey:@"params"];
            NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:paramData options:NSJSONReadingAllowFragments error:nil];
            self.segueModel = [[AESegueModel alloc] initWithDestination:dest paramRawData:paramDic];
        }
    }
    return self;
}

@end
