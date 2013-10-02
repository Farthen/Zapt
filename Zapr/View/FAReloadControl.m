//
//  FAReloadControl.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAReloadControl.h"
#import "CGFunctions.h"

@interface FAReloadControl ()
@property UIActivityIndicatorView *activityIndicatorView;

@property (readonly) CGRect contentRect;
@end

@implementation FAReloadControl {
    FAReloadControlState _reloadControlState;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setUp];
}

- (void)setUp
{
    self.reloadControlState = FAReloadControlStateError;
}

- (CGRect)contentRect
{
    CGRect rect = self.bounds;
    CGFloat size = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
    rect.size.width = size;
    rect.size.height = size;
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    
    rect = CGRectCenteredToPoint(rect.size, center);
    
    return CGRectCenteredToPoint(CGSizeMake(24, 24), center);
    
    return rect;
}

- (void)addActivityIndicatorViewIfNeeded
{
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    if (!self.activityIndicatorView.superview) {
        self.activityIndicatorView.frame = self.contentRect;
        self.activityIndicatorView.userInteractionEnabled = NO;
        
        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
}

- (void)removeActivityIndicatorViewIfNeeded
{
    if (self.activityIndicatorView.superview) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
    }
}

- (void)setReloadControlState:(FAReloadControlState)reloadControlState
{
    if (reloadControlState != FAReloadControlStateReloading) {
        [self removeActivityIndicatorViewIfNeeded];
    } else if (reloadControlState == FAReloadControlStateReloading) {
        [self addActivityIndicatorViewIfNeeded];
    }
        
    _reloadControlState = reloadControlState;
        
    [self setNeedsDisplay];
}

- (FAReloadControlState)reloadControlState
{
    return _reloadControlState;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        
        // The touch area is a minimum of 44x44
        CGSize touchArea;
        touchArea.height = MAX(self.bounds.size.height, 44);
        touchArea.width = MAX(self.bounds.size.width, 44);
        
        CGPoint center = CGRectCenter(self.bounds);
        CGRect touchRect = CGRectCenteredToPoint(touchArea, center);
        
        return CGRectContainsPoint(touchRect, point);
    }
    
    return [super pointInside:point withEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    rect = self.contentRect;
    
    [[UIColor whiteColor] set];
    
    
    if (self.reloadControlState == FAReloadControlStateError) {
        // Draw a circle with an arrowhead
        
        if (self.highlighted) {
            [[UIColor colorWithWhite:1 alpha:0.7] set];
        }
        
        // configurable parameters
        CGFloat circleThickness = 2;
        CGFloat arrowWidth = circleThickness * 4;
        CGFloat arrowHeight = arrowWidth / 2;
        
        // Draw the circle
        CGFloat insetValue = circleThickness / 2 + arrowWidth / 2;
        CGRect circleRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(insetValue, insetValue, insetValue, insetValue));
        
        CGPoint center = CGPointMake(circleRect.origin.x + circleRect.size.width / 2, circleRect.origin.y + circleRect.size.height / 2);
        CGFloat outerRadius = MIN(CGRectGetHeight(circleRect), CGRectGetWidth(circleRect)) / 2;
        
        CGFloat startAngle = M_PI;
        CGFloat endAngle = 3 * M_PI_4;
        CGFloat pathRadius = outerRadius - (circleThickness / 2);
        CGPoint beginPoint = CGPointMake(center.x - pathRadius, center.y);
        
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        [circlePath moveToPoint:beginPoint];
        circlePath.lineWidth = circleThickness;
        
        [circlePath addArcWithCenter:center radius:pathRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        [circlePath stroke];
        
        // Draw the arrowhead
        
        CGPoint upperLeftPoint = CGPointMake(beginPoint.x - arrowWidth / 2, beginPoint.y);
        CGPoint upperRightPoint = CGPointMake(beginPoint.x + arrowWidth / 2, beginPoint.y);
        CGPoint tipPoint = CGPointMake(beginPoint.x, beginPoint.y + arrowHeight);
        
        UIBezierPath *arrowPath = [UIBezierPath bezierPath];
        arrowPath.lineWidth = 1;
        [arrowPath moveToPoint:beginPoint];
        [arrowPath addLineToPoint:upperLeftPoint];
        [arrowPath addLineToPoint:tipPoint];
        [arrowPath addLineToPoint:upperRightPoint];
        [arrowPath addLineToPoint:beginPoint];
        
        [arrowPath fill];
        
    } else if (self.reloadControlState == FAReloadControlStateFinished) {
        // Draw a checkmark
        
        // configurable parameters
        CGFloat checkmarkThickness = 2;
        
        // How long should the left leg be compared to the right one?
        CGFloat ratio = 0.4;
        
        // Draw the checkmark
        CGFloat inset = checkmarkThickness / 2;
        rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(inset, inset, inset, inset));
        
        CGFloat upperY = rect.origin.y + rect.size.height * 0.25;
        CGFloat lowerY = rect.origin.y + rect.size.height * 0.75;
        
        CGPoint rightPoint = CGPointMake(rect.origin.x + rect.size.width, upperY);
        CGPoint leftMaxPoint = CGPointMake(rect.origin.x, upperY);
        CGPoint tipPoint = CGPointMake(rect.origin.x + rect.size.height / 2, lowerY);
        
        CGPoint leftLengthMax = CGPointSubtract(leftMaxPoint, tipPoint);
        CGPoint leftLength = CGPointMultiply(leftLengthMax, ratio);
        CGPoint leftPoint = CGPointAdd(tipPoint, leftLength);
        
        UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
        checkmarkPath.lineWidth = checkmarkThickness;
        
        [checkmarkPath moveToPoint:leftPoint];
        [checkmarkPath addLineToPoint:tipPoint];
        [checkmarkPath addLineToPoint:rightPoint];
        
        [checkmarkPath stroke];
    }
}


@end
