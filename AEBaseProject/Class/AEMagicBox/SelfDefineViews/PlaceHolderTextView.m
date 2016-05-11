//
//  PlaceHolderTextView.m
//  iPhone51Buy
//
//  Created by Bai Haoquan on 13-4-23.
//  Copyright (c) 2013年 icson. All rights reserved.
//

#import "PlaceHolderTextView.h"

@implementation PlaceHolderTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setText:self.placeHolderStr];
        [self setTextColor:self.placeHolderColor];
        [self setFont:self.placeHolderFont];
        [self setPlaceHolderColor:RGBA(153.0, 153.0, 153.0, 1.0)];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setText:self.placeHolderStr];
        [self setTextColor:RGBA(68.0, 68.0, 68.0, 1.0)];
        [self setFont:[UIFont systemFontOfSize:15.0f]];
        [self setPlaceHolderColor:RGBA(153.0, 153.0, 153.0, 1.0)];
    }
    
    return self;
}

- (NSString *)text {
    if (self.isPlaceHolderState) {
        return @"";
    } else {
        return [super text];
    }
}

//- (void)setDelegate:(id<UITextViewDelegate>)delegate
//{
//    // disable self.delegate, use newDelegate instead
//    return;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setIsPlaceHolderState:(BOOL)isPlaceHolderState
{
    _isPlaceHolderState = isPlaceHolderState;
    if (isPlaceHolderState)
    {
        [self setText:self.placeHolderStr];
        [self setTextColor:self.placeHolderColor];
        [self setFont:self.placeHolderFont];
    }
    else
    {
        [self setTextColor:self.contentColor];
        [self setFont:self.contentFont];
    }
}

@end
