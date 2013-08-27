//
//  UIView+FrameAdditions.h
//  Zapr
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameAdditions)

@property (assign) CGFloat frameX;
@property (assign) CGFloat frameY;
@property (assign) CGFloat frameWidth;
@property (assign) CGFloat frameHeight;
@property (assign) CGFloat frameTopPosition;
@property (assign) CGFloat frameBottomPosition;
@property (assign) CGFloat frameLeftPosition;
@property (assign) CGFloat frameRightPosition;

@property (assign) CGPoint frameOrigin;
- (void) frameAddOrigin:(CGPoint)origin;
- (void) frameSubtractOrigin:(CGPoint)origin;

@property (assign) CGSize frameSize;
- (void) frameAddSize:(CGSize)size;
- (void) frameSubtractSize:(CGSize)size;


@property (assign) CGFloat boundsX;
@property (assign) CGFloat boundsY;
@property (assign) CGFloat boundsWidth;
@property (assign) CGFloat boundsHeight;
@property (assign) CGFloat boundsTopPosition;
@property (assign) CGFloat boundsBottomPosition;
@property (assign) CGFloat boundsLeftPosition;
@property (assign) CGFloat boundsRightPosition;

@property (assign) CGPoint boundsOrigin;
- (void) boundsAddOrigin:(CGPoint)origin;
- (void) boundsSubtractOrigin:(CGPoint)origin;

@property (assign) CGSize boundsSize;
- (void) boundsAddSize:(CGSize)size;
- (void) boundsSubtractSize:(CGSize)size;


@property (assign) CGFloat centerX;
@property (assign) CGFloat centerY;

@end
