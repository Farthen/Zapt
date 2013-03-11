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
@property (assign) CGFloat frameY;
@property (assign) CGFloat frameWidth;
@property (assign) CGFloat frameHeight;
@property (assign) CGPoint frameOrigin;
@property (assign) CGSize frameSize;

@property (assign) CGFloat boundsX;
@property (assign) CGFloat boundsY;
@property (assign) CGFloat boundsWidth;
@property (assign) CGFloat boundsHeight;
@property (assign) CGPoint boundsOrigin;
@property (assign) CGSize boundsSize;

@property (assign) CGFloat centerX;
@property (assign) CGFloat centerY;

@end
