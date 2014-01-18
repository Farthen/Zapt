//
//  FAUnreadItemIndicatorView.m
//  Zapt
//
//  Created by Finn Wilke on 27.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAUnreadItemIndicatorView.h"

@implementation FAUnreadItemIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    rect = self.bounds;
    
    CGRect circleRect;
    CGFloat size = MIN(rect.size.height, rect.size.width);
    
    circleRect.origin.x = rect.origin.x + ((rect.size.width - size) / 2);
    circleRect.origin.y = rect.origin.y + ((rect.size.height - size) / 2);
    
    circleRect.size = CGSizeMake(size, size);
    
    circleRect = CGRectInset(circleRect, 2, 2);
    
    [self.tintColor set];
    CGContextFillEllipseInRect(context, circleRect);
}

@end
