//
//  FAIndicatorView.m
//  Zapr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAIndicatorView.h"
#import "CGFunctions.h"

@implementation FAIndicatorView {
    BOOL _isFlipped;
    
    FAIndicatorViewArrowDirection _arrowDirection;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (CGRect)arrowRect
{
    CGRect arrowRect;
    arrowRect.size.width = 14;
    arrowRect.size.height = 20;
    arrowRect = CGRectCenteredToPoint(arrowRect.size, CGRectCenter(self.bounds));
    return arrowRect;
}

- (void)flip:(BOOL)doFlip
{
    _isFlipped = doFlip;
    [self setNeedsDisplay];
}

- (void)setArrowDirection:(FAIndicatorViewArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // We will be drawing a rectangular indicator arrow to show that this view can reveal more stuff
    //CGContextClearRect(context,rect);
    
    // Set the arrow frame. It will be a 20x20 rect centered in the middle
    
    CGRect arrowRect = [self arrowRect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the arrow color
    CGColorRef arrowColorRef = [self.tintColor CGColor];
    
    CGPoint midPoint = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMidY(arrowRect));
    
    CGContextSetFillColorWithColor(context, arrowColorRef);
    
    // Check if we should rotate the coordinate system.
    if (_arrowDirection == FAIndicatorViewArrowDirectionUp || _arrowDirection == FAIndicatorViewArrowDirectionDown) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(arrowRect.size.height * 2, 0.0);
        transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        CGContextConcatCTM(context, transform);
    }
    
    // Check if we should flip coordinate system. If we should flip twice, don't flip ;)
    if (_isFlipped != (_arrowDirection == FAIndicatorViewArrowDirectionRight || _arrowDirection == FAIndicatorViewArrowDirectionDown)) {
        // stolen! http://stackoverflow.com/a/7870597/1084385
        CGAffineTransform flipVertical = CGAffineTransformMake(-1, 0, 0, 1, rect.size.width, 0);
        CGContextConcatCTM(context, flipVertical);
    }
    
    // draw the lower leg
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, midPoint.x, midPoint.y);
    CGContextAddLineToPoint(context, midPoint.x + 10, midPoint.y + 10);
    CGContextAddLineToPoint(context, midPoint.x + 12, midPoint.y + 8);
    CGContextAddLineToPoint(context, midPoint.x + 4, midPoint.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    // draw the upper leg
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, midPoint.x, midPoint.y);
    CGContextAddLineToPoint(context, midPoint.x + 10, midPoint.y - 10);
    CGContextAddLineToPoint(context, midPoint.x + 12, midPoint.y - 8);
    CGContextAddLineToPoint(context, midPoint.x + 4, midPoint.y);
    CGContextClosePath(context);
    
    CGContextFillPath(context);
}


@end
