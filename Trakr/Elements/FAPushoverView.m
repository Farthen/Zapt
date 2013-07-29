//
//  FAPushoverView.m
//  Trakr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAPushoverView.h"
#import "FAIndicatorView.h"
#import "FAMaskingView.h"

#import "UIView+FrameAdditions.h"

// This is a view that shows a full height, small width indicator on the right side.
// Tapping/sliding it reveals the view
@implementation FAPushoverView {
    BOOL _isActive;
    FAIndicatorView *_indicatorView;
    CGSize _indicatorSize;
    
    UIView *_contentView;
    UIView *_backgroundView;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    CGPoint _panOrigin;
    BOOL _isPanning;
    CGFloat _lastdX;
        
    id <FAPushoverViewDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isActive = NO;
        [self awakeFromNib];
        self.indicatorSize = CGSizeMake(40, frame.size.height);
    }
    return self;
}

- (void)awakeFromNib
{
    self.indicatorSize = CGSizeMake(40, 0);
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    //_backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    _backgroundView.backgroundColor = [UIColor clearColor];

    _backgroundView.frame = [self backgroundViewFrame];
    [self addSubview:_backgroundView];
}

- (void)hideContentView:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(pushoverView:willHideContentView:)]) {
        [self.delegate pushoverView:self willHideContentView:animated];
    }
    _isActive = NO;
    CGFloat duration = animated ? 0.3f: 0;
    [UIView transitionWithView:_indicatorView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_indicatorView flip:NO];
    } completion:nil];
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = [self contentViewFrame];
        _backgroundView.frame = [self backgroundViewFrame];
    } completion:^(BOOL finished){
        if (finished) {
            if ([self.delegate respondsToSelector:@selector(pushoverViewDidHideContentView:)]) {
                [self.delegate pushoverViewDidHideContentView:self];
            }
        }
    }];
}

- (void)showContentView:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(pushoverView:willShowContentView:)]) {
        [self.delegate pushoverView:self willShowContentView:animated];
    }
    _isActive = YES;
    CGFloat duration = animated ? 0.3f: 0;
    
    [UIView transitionWithView:_indicatorView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [_indicatorView flip:YES];
    } completion:nil];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.contentView.frame = [self contentViewFrame];
        _backgroundView.frame = [self backgroundViewFrame];
    } completion:^(BOOL finished){
        if (finished) {
            if ([self.delegate respondsToSelector:@selector(pushoverViewDidShowContentView:)]) {
                [self.delegate pushoverViewDidShowContentView:self];
            }
        }
    }];
}

- (void)evaluateGesture:(UIGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:_backgroundView];
    if (recognizer == _panGestureRecognizer) {
        if(recognizer.state == UIGestureRecognizerStateBegan) {
            if (CGRectContainsPoint(self.indicatorFrame, location)) {
                _isPanning = YES;
                _panOrigin = [recognizer locationInView:self];
            } else {
                _isPanning = NO;
            }
        }
        if (_isPanning) {
            CGPoint newCoord = [recognizer locationInView:self];
            float dX = newCoord.x - _panOrigin.x;
            //float dY = newCoord.y - _panOrigin.y;
            
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                _isPanning = NO;
                CGPoint velocity = [_panGestureRecognizer velocityInView:self];
                if (velocity.x < -10) {
                    [self showContentView:YES];
                } else if(_isActive && velocity.x < 0) {
                    [self showContentView:YES];
                } else {
                    [self hideContentView:YES];
                }
            } else {
                //[CATransaction begin];
                
                // Move the background view by the dX
                CGRect backgroundFrame = [self backgroundViewFrame];
                CGFloat fullWidth = [self backgroundViewFrameForState:NO].origin.x - self.bounds.origin.x;
                //CGFloat reducedHeight = [self backgroundViewFrameForState:NO].size.height;
                CGFloat fraction = MAX(0, 1 - ((backgroundFrame.origin.x + dX) / fullWidth));
                fraction = MIN(fraction, 1);
                _backgroundView.frameX = MAX(0, backgroundFrame.origin.x + dX);
                //_backgroundView.frameHeight = reducedHeight + (fraction * (self.boundsHeight - reducedHeight));
                
                if ([self.delegate respondsToSelector:@selector(pushoverView:isAtFractionForHeightAnimation:)]) {
                    [self.delegate pushoverView:self isAtFractionForHeightAnimation:fraction];
                }
                
                //[CATransaction commit];
            }
        }
    } else {
        if (CGRectContainsPoint(self.indicatorFrame, location)) {
            if (!_isActive) {
                [self showContentView:YES];
            } else {
                [self hideContentView:YES];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer  shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (CGRectContainsPoint(self.indicatorFrame, [gestureRecognizer locationInView:_backgroundView])) {
        return NO;
    }
    if (_isPanning) {
        return NO;
    }
    return YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(evaluateGesture:)];
        [self addGestureRecognizer:_tapGestureRecognizer];
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(evaluateGesture:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
    } else {
        _tapGestureRecognizer = nil;
        _panGestureRecognizer = nil;
    }
}

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    _contentView = contentView;
    _contentView.frame = self.contentViewFrame;
    [_backgroundView addSubview:_contentView];
}

- (UIView *)contentView
{
    return _contentView;
}

- (CGRect)contentViewFrame
{
    CGRect frame = _backgroundView.bounds;
    frame.size.width -= self.indicatorSize.width;
    frame.origin.x = _backgroundView.bounds.origin.x + self.indicatorSize.width;
    return frame;
}

- (UIView *)backgroundView
{
    return _backgroundView;
}

- (CGRect)backgroundViewFrame
{
    return [self backgroundViewFrameForState:_isActive];
}

- (CGRect)backgroundViewFrameForState:(BOOL)active
{
    CGRect frame = self.bounds;
    frame.size = self.bounds.size;
    if (!active) {
        frame.origin.x = frame.origin.x + (self.bounds.size.width - self.indicatorSize.width);
        //frame.size.height = _indicatorSize.height;
        return frame;
    } else {
        frame.origin = self.bounds.origin;
        return frame;
    }
}

- (CGRect)indicatorFrame
{
    CGRect frame;
    frame.origin = _backgroundView.bounds.origin;
    frame.size = self.indicatorSize;
    return frame;
}

- (void)setIndicatorSize:(CGSize)indicatorSize
{
    _indicatorSize = indicatorSize;
    _indicatorView.frameSize = indicatorSize;
    _backgroundView.frame = [self backgroundViewFrame];
    [_indicatorView setNeedsDisplay];
}

- (CGSize)indicatorSize
{
    return _indicatorSize;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.indicatorSize.height == 0) {
        CGSize indicatorSize = self.indicatorSize;
        indicatorSize.height = rect.size.height;
        self.indicatorSize = indicatorSize;
    }
    // Drawing code
    if (!_isActive) {
        // draw the small indicator thing to the right
        if (!_indicatorView) {
            // Set its frame to the specified rect and add it to the subview
            CGRect frame = self.indicatorFrame;
            _indicatorView = [[FAIndicatorView alloc] initWithFrame:frame];
            [_backgroundView addSubview:_indicatorView];
        }
    }
}

#pragma mark Delegate
- (id<FAPushoverViewDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<FAPushoverViewDelegate>)delegate
{
    _delegate = delegate;
}


@end
