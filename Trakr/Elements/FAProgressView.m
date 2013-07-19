//
//  FAProgressView.m
//  Trakr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAProgressView.h"

@implementation FAProgressView
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect coloredRect = rect;
    coloredRect.size.width *= _progress;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef yellow = [[UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1] CGColor];
    
    CGContextSetFillColorWithColor(context, yellow);
    CGContextFillRect(context, coloredRect);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (CGFloat)progress
{
    return _progress;
}


@end
