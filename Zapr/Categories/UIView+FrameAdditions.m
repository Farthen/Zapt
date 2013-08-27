//
//  UIView+FrameAdditions.m
//  Zapr
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+FrameAdditions.h"
#import "CGFunctions.h"

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

- (CGFloat)frameTopPosition
{
    return self.frame.origin.y;
}

- (void)setFrameTopPosition:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)frameBottomPosition
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setFrameBottomPosition:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)frameLeftPosition
{
    return self.frame.origin.x;
}

- (void)setFrameLeftPosition:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)frameRightPosition
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRightPosition:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
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

- (void)frameAddOrigin:(CGPoint)origin
{
    self.frameOrigin = CGPointAdd(self.frameOrigin, origin);
}

- (void)frameSubtractOrigin:(CGPoint)origin
{
    self.frameOrigin = CGPointSubtract(self.frameOrigin, origin);
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

- (void)frameAddSize:(CGSize)size
{
    self.frameSize = CGSizeAdd(self.frameSize, size);
}

- (void)frameSubtractSize:(CGSize)size
{
    self.frameSize = CGSizeSubtract(self.frameSize, size);
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

- (CGFloat)boundsTopPosition
{
    return self.bounds.origin.y;
}

- (void)setBoundsTopPosition:(CGFloat)top
{
    CGRect bounds = self.bounds;
    bounds.origin.y = top;
    self.bounds = bounds;
}

- (CGFloat)boundsBottomPosition
{
    return self.bounds.origin.y + self.bounds.size.height;
}

- (void)setBoundsBottomPosition:(CGFloat)bottom
{
    CGRect bounds = self.bounds;
    bounds.origin.y = bottom - bounds.size.height;
    self.bounds = bounds;
}

- (CGFloat)boundsLeftPosition
{
    return self.bounds.origin.x;
}

- (void)setBoundsLeftPosition:(CGFloat)left
{
    CGRect bounds = self.bounds;
    bounds.origin.x = left;
    self.bounds = bounds;
}

- (CGFloat)boundsRightPosition
{
    return self.bounds.origin.x + self.bounds.size.width;
}

- (void)setBoundsRightPosition:(CGFloat)right
{
    CGRect bounds = self.bounds;
    bounds.origin.x = right - bounds.size.width;
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

- (void)boundsAddOrigin:(CGPoint)origin
{
    self.boundsOrigin = CGPointAdd(self.boundsOrigin, origin);
}

- (void)boundsSubtractOrigin:(CGPoint)origin
{
    self.boundsOrigin = CGPointSubtract(self.boundsOrigin, origin);
}

- (CGSize)boundsSize
{
    return self.bounds.size;
}

- (void)setBoundsSize:(CGSize)size
{
    CGRect bounds = self.bounds;
    bounds.size = size;
    self.bounds = bounds;
}

- (void)boundsAddSize:(CGSize)size
{
    self.boundsSize = CGSizeAdd(self.boundsSize, size);
}

- (void)boundsSubtractSize:(CGSize)size
{
    self.boundsSize = CGSizeSubtract(self.boundsSize, size);
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
