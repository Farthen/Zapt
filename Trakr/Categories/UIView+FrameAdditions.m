//
//  UIView+FrameAdditions.m
//  Trakr
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

- (void)frameAddX:(CGFloat)x
{
    self.frameX = self.frameX + x;
}

- (void)frameSubtractX:(CGFloat)x
{
    self.frameX = self.frameX - x;
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

- (void)frameAddY:(CGFloat)y
{
    self.frameY = self.frameY + y;
}

- (void)frameSubtractY:(CGFloat)y
{
    self.frameY = self.frameY - y;
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

- (void)frameAddWidth:(CGFloat)width
{
    self.frameWidth = self.frameWidth + width;
}

- (void)frameSubtractWidth:(CGFloat)width
{
    self.frameWidth = self.frameWidth - width;
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

- (void)frameAddHeight:(CGFloat)height
{
    self.frameHeight = self.frameHeight + height;
}

- (void)frameSubtractHeight:(CGFloat)height
{
    self.frameHeight = self.frameHeight - height;
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

- (void)boundsAddX:(CGFloat)x
{
    self.boundsX = self.boundsX + x;
}

- (void)boundsSubtractX:(CGFloat)x
{
    self.boundsX = self.boundsX - x;
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

- (void)boundsAddY:(CGFloat)y
{
    self.boundsY = self.boundsY + y;
}

- (void)boundsSubtractY:(CGFloat)y
{
    self.boundsY = self.boundsY - y;
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

- (void)boundsAddWidth:(CGFloat)width
{
    self.boundsWidth = self.boundsWidth + width;
}

- (void)boundsSubtractWidth:(CGFloat)width
{
    self.boundsWidth = self.boundsWidth - width;
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

- (void)boundsAddHeight:(CGFloat)height
{
    self.boundsHeight = self.boundsHeight + height;
}

- (void)boundsSubtractHeight:(CGFloat)height
{
    self.boundsHeight = self.boundsHeight - height;
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

- (void)centerAddX:(CGFloat)x
{
    self.centerX = self.centerX + x;
}

- (void)centerSubtractX:(CGFloat)x
{
    self.centerX = self.centerX - x;
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

- (void)centerAddY:(CGFloat)y
{
    self.centerY = self.centerY + y;
}

- (void)centerSubtractY:(CGFloat)y
{
    self.centerY = self.centerY - y;
}

@end
