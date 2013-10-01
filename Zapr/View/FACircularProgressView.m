//
//  FACheckinProgressView.m
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACircularProgressView.h"
#import <math.h>

@interface FACircularProgressView ()
@property UILabel *label;
@end

@implementation FACircularProgressView {
    CGFloat _progress;
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
    self.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.circleThickness = 40;
    self.label = [[UILabel alloc] initWithFrame:[self labelFrame]];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self addSubview:self.label];
}

- (CGFloat)progress
{
    return _progress;
}

- (void)setProgress:(CGFloat)progress
{
    progress = MIN(progress, 1);
    progress = MAX(progress, 0);
    _progress = progress;
    [self setNeedsDisplay];
}

- (CGRect)labelFrame
{
    CGRect rect = self.bounds;
    rect = UIEdgeInsetsInsetRect(rect, self.contentInset);
    CGFloat circleThickness = self.circleThickness;
    rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(circleThickness, circleThickness, circleThickness, circleThickness));
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    
    // Reduce the diagonal length to the radius
    CGFloat radius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2;
    
    // 2 * a^2 = b^2 which means a = sqrt(b^2 / 2)
    CGFloat length = sqrtf(radius * radius / 2) * 2;
    rect.size.height = length;
    rect.size.width = length;
    rect.origin.x = center.x - rect.size.width / 2;
    rect.origin.y = center.y - rect.size.height / 2;
    
    return rect;
}

- (void)drawRect:(CGRect)rect
{
    // Center:
    rect = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
    CGFloat outerRadius = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect)) / 2;
    
    CGFloat fraction = self.progress;
    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = 2 * M_PI * fraction + startAngle;
    CGFloat circleThickness = self.circleThickness;
    CGFloat pathRadius = outerRadius - (circleThickness / 2);
    CGPoint begin = CGPointMake(center.x, center.y - pathRadius);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath moveToPoint:begin];
    circlePath.lineWidth = circleThickness;
    [circlePath addArcWithCenter:center radius:pathRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    [self.tintColor set];
    [circlePath stroke];
}


@end
