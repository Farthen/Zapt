//
//  FAArrowView.m
//  Zapt
//
//  Created by Finn Wilke on 13/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAArrowView.h"

@implementation FAArrowView {
    CGFloat _progress;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, self.intrinsicContentSize.width, self.intrinsicContentSize.height);
        self.opaque = NO;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(40, 20);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    rect = self.bounds;
    
    CGFloat margin = 6;
    CGFloat lineWidth = 2;
    
    CGFloat leftX = rect.origin.x + margin;
    CGFloat rightX = rect.origin.x + rect.size.width - margin;
    CGFloat midX = rect.origin.x + (rect.size.width / 2);
    
    CGFloat midY = rect.origin.y + margin;
    CGFloat arrowY = rect.size.height - margin;
    
    CGFloat interpolatedY = (_progress * (arrowY - midY)) + midY;
    
    [[UIColor darkGrayColor] set];
    
    if (self.upArrow) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        // reverse the y-axis
        CGContextScaleCTM(context, 1, -1);
        // move the origin to put the drawing back in the visible area
        CGContextTranslateCTM(context, 0, -self.bounds.size.height);
    }
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(leftX, midY)];
    [line addLineToPoint:CGPointMake(midX, interpolatedY)];
    [line addLineToPoint:CGPointMake(rightX, midY)];
    line.lineWidth = lineWidth;
    line.lineCapStyle = kCGLineCapRound;
    [line stroke];
}


@end
