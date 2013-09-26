//
//  FAProgressView.m
//  Zapr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAProgressView.h"
#import "FATraktContent.h"
#import "FAContentTableViewCell.h"
#import "UIView+FrameAdditions.h"

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

- (CGFloat)progressBarHeight
{
    return self.bounds.size.height;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect coloredRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.progressBarHeight);
    coloredRect.size.width *= _progress;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef tintColor = self.tintColor.CGColor;
    
    CGContextSetFillColorWithColor(context, tintColor);
    CGContextFillRect(context, coloredRect);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setNextUpContent:(FATraktContent *)nextUpContent
{
}

- (CGFloat)progress
{
    return _progress;
}


@end
