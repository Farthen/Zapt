//
//  FAPushoverViewAnimationController.m
//  Trakr
//
//  Created by Finn Wilke on 25.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAPushoverViewAnimationController.h"
#import "FAPushoverView.h"
#import "FAMaskingView.h"
#import "FATitleLabel.h"

@implementation FAPushoverViewAnimationController {
    FAPushoverView *_pushoverView;
    FAMaskingView *_maskingView;
    FATitleLabel *_titleLabel;
    NSLayoutConstraint *_titleLabelConstraint;
    
    CADisplayLink *_displayLink;
    
    BOOL _animating;
    
    //CGFloat _pushoverViewBeginXValue;
    CGRect _pushoverViewEndRect;
    
    CGFloat _titleLabelBeginConstraintValue;
    
    CGFloat _pushoverViewEndXValue;
    CGFloat _titleLabelEndConstraintValue;
    
    CFTimeInterval _beginTimestamp;
    CFTimeInterval _endTimestamp;
    CFTimeInterval _animationDuration;
}

- (instancetype) initWithPushoverView:(FAPushoverView *)pushoverView maskingView:(FAMaskingView *)maskingView titleLabel:(FATitleLabel *)titleLabel titleLabelConstraint:(NSLayoutConstraint *)titleLabelConstraint
{
    self = [super init];
    if (self) {
        _pushoverView = pushoverView;
        _pushoverView.delegate = self;
        _maskingView = maskingView;
        _titleLabel = titleLabel;
        _titleLabelConstraint = titleLabelConstraint;
        _animationDuration = 0.3f;
    }
    return self;
}

- (void)cleanup
{
    // We are done here. Set the stuff to the end values
    CGRect frame = _pushoverView.backgroundView.frame;
    frame.origin.x = _pushoverViewEndXValue;
    _pushoverView.backgroundView.frame = frame;
    
    _titleLabelConstraint.constant = _titleLabelEndConstraintValue;
    [_titleLabel.superview layoutIfNeeded];
    
    // Remove the CADisplayLink
    [_displayLink invalidate];
    _displayLink = nil;
    
    //We are done here. Great job!
    _animating = NO;
}

- (void)animate
{
    // Create a new CALayerAnimation for the pushover view
    CABasicAnimation *pushoverAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    pushoverAnimation.toValue = [NSValue valueWithCGRect:_pushoverViewEndRect];
    pushoverAnimation.duration = 0.3;
    [_pushoverView.backgroundView.layer addAnimation:pushoverAnimation forKey:nil];
    
    // Create a new CALayerAnimation for the title view
    //CABasicAnimation *titleAnimation = [CABasicAnimation animationWithKeyPath:@"animateTitleView"];
    
}

- (void)pushoverView:(FAPushoverView *)pushoverView willHideContentView:(BOOL)animated
{
    [self animateHide];
}

- (void)pushoverView:(FAPushoverView *)pushoverView willShowContentView:(BOOL)animated
{
    [self animateShow];
}

- (void)animateHide
{
    if (!_animating) {
        // We will be animating the whole thing by hand because otherwise everything will be off
        _animating = YES;
        
        // Find out the current constraint values of the pushoverView and the titleLabel
        //_pushoverViewBeginXValue = _pushoverView.backgroundView.frame.origin.x;
        //_titleLabelBeginConstraintValue = _titleLabelConstraint.constant;
        
        // Set the end frames
        // Animate the pushoverView to the left until the frame x position is zero
        
        _pushoverViewEndXValue = _pushoverView.bounds.size.width - _pushoverView.indicatorSize.width;
        
        // Animate the titleLabel until the constraint is at - intrinsic content height of the title label
        _titleLabelEndConstraintValue = - _titleLabel.intrinsicContentSize.height;
        
        [self animate];
    }
}


- (void)animateShow
{
    if (!_animating) {
        // We will be animating the whole thing by hand because otherwise everything will be off
        _animating = YES;
        
        // Find out the current constraint values of the pushoverView and the titleLabel
        //_titleLabelBeginConstraintValue = _titleLabelConstraint.constant;
        
        // Set the end frames
        // Animate the pushoverView to the left until the frame x position is zero
        //_pushoverViewEndXValue = - _pushoverView.backgroundView.frame.origin.x;
        _pushoverViewEndRect = _pushoverView.backgroundView.layer.bounds;
        _pushoverViewEndRect.origin = [_pushoverView.layer convertPoint:CGPointMake(0, 0) toLayer:_pushoverView.backgroundView.layer];

        
        // Animate the titleLabel until the constraint is at - intrinsic content height of the title label
        //_titleLabelEndConstraintValue = 0;
        
        [self animate];
    }
}

@end
