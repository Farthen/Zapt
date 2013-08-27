//
//  FAMaskingView.h
//  Zapr
//
//  Created by Finn Wilke on 25.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAMaskingView : UIView

- (void)addMaskLayer:(CALayer *)layer;
- (void)removeMaskLayer:(CALayer *)layer;
- (void)update;
- (void)stopUpdatingContinuously;
- (void)updateContinuously;
- (void)updateContinuouslyFor:(NSTimeInterval)seconds;

- (void)setOverrideRect:(CGRect)rect forLayer:(CALayer *)layer;
- (void)removeOverrideRectForLayer:(CALayer *)layer;

- (void)setMaskedImage:(UIImage *)image;

@end
