//
//  UIView+FrameAdditions.m
//  Trakr
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+FrameAdditions.h"

@implementation UIView (FrameAdditions)

#pragma mark frame

- (CGFloat)frameX
{
    return self.frame.origin.x;
}

- (void)setFrameX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)frameY
{
    return self.frame.origin.y;
}

- (void)setFrameY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)frameWidth
{
    return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)frameHeight
{
    return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)frameOrigin
{
    return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)frameSize
{
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

#pragma mark bounds

- (CGFloat)boundsX
{
    return self.bounds.origin.x;
}

- (void)setBoundsX:(CGFloat)x
{
    CGRect bounds = self.bounds;
    bounds.origin.x = x;
    self.bounds = bounds;
}

- (CGFloat)boundsY
{
    return self.bounds.origin.y;
}

- (void)setBoundsY:(CGFloat)y
{
    CGRect bounds = self.bounds;
    bounds.origin.y = y;
    self.bounds = bounds;
}

- (CGFloat)boundsWidth
{
    return self.bounds.size.width;
}

- (void)setBoundsWidth:(CGFloat)width
{
    CGRect bounds = self.bounds;
    bounds.size.width = width;
    self.bounds = bounds;
}

- (CGFloat)boundsHeight
{
    return self.bounds.size.height;
}

- (void)setBoundsHeight:(CGFloat)height
{
    CGRect bounds = self.bounds;
    bounds.size.height = height;
    self.bounds = bounds;
}

- (CGPoint)boundsOrigin
{
    return self.bounds.origin;
}

- (void)setBoundsOrigin:(CGPoint)origin
{
    CGRect bounds = self.bounds;
    bounds.origin = origin;
    self.bounds = bounds;
}

- (CGSize)boundsSize
{
    return self.bounds.size;
}

- (void)setboundsSize:(CGSize)size
{
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

#pragma mark center

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)x
{
    CGPoint center = self.center;
    center.x = x;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)y
{
    CGPoint center = self.center;
    center.y = y;
    self.center = center;
}

@end
