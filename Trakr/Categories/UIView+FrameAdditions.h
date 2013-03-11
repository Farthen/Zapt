//
//  UIView+FrameAdditions.h
//  Trakr
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameAdditions)

@property (assign) CGFloat frameX;
- (void) frameAddX:(CGFloat)x;
- (void) frameSubtractX:(CGFloat)x;

@property (assign) CGFloat frameY;
- (void) frameAddY:(CGFloat)y;
- (void) frameSubtractY:(CGFloat)y;

@property (assign) CGFloat frameWidth;
- (void) frameAddWidth:(CGFloat)width;
- (void) frameSubtractWidth:(CGFloat)width;

@property (assign) CGFloat frameHeight;
- (void) frameAddHeight:(CGFloat)height;
- (void) frameSubtractHeight:(CGFloat)height;

@property (assign) CGPoint frameOrigin;
- (void) frameAddOrigin:(CGPoint)origin;
- (void) frameSubtractOrigin:(CGPoint)origin;

@property (assign) CGSize frameSize;
- (void) frameAddSize:(CGSize)size;
- (void) frameSubtractSize:(CGSize)size;



@property (assign) CGFloat boundsX;
- (void) boundsAddX:(CGFloat)x;
- (void) boundsSubtractX:(CGFloat)x;

@property (assign) CGFloat boundsY;
- (void) boundsAddY:(CGFloat)y;
- (void) boundsSubtractY:(CGFloat)y;

@property (assign) CGFloat boundsWidth;
- (void) boundsAddWidth:(CGFloat)width;
- (void) boundsSubtractWidth:(CGFloat)width;

@property (assign) CGFloat boundsHeight;
- (void) boundsAddHeight:(CGFloat)height;
- (void) boundsSubtractHeight:(CGFloat)height;

@property (assign) CGPoint boundsOrigin;
- (void) boundsAddOrigin:(CGPoint)origin;
- (void) boundsSubtractOrigin:(CGPoint)origin;

@property (assign) CGSize boundsSize;
- (void) boundsAddSize:(CGSize)size;
- (void) boundsSubtractSize:(CGSize)size;



@property (assign) CGFloat centerX;
- (void) centerAddX:(CGFloat)x;
- (void) centerSubtractX:(CGFloat)x;

@property (assign) CGFloat centerY;
- (void) centerAddY:(CGFloat)y;
- (void) centerSubtractY:(CGFloat)y;

@end
