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
        //self.indicatorSize = CGSizeMake(40, frame.size.height);
    }
    return self;
}

- (void)awakeFromNib
{
    //self.indicatorSize = CGSizeMake(0, 40);
    self.indicatorSize = CGSizeMake(40, 0);
    self.indicatorLocation = FAPushoverViewIndicatorLocationRight;
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
            float dY = newCoord.y - _panOrigin.y;
            
            if (recognizer.state == UIGestureRecognizerStateEnded) {
                _isPanning = NO;
                CGPoint velocity = [_panGestureRecognizer velocityInView:self];
                CGFloat velocityTowardsActive = 0;
                if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight) {
                    velocityTowardsActive = - velocity.x;
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
                    velocityTowardsActive = velocity.x;
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
                    velocityTowardsActive = velocity.y;
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
                    velocityTowardsActive = - velocity.y;
                }
                if (velocityTowardsActive > 10) {
                    [self showContentView:YES];
                } else if(_isActive && velocityTowardsActive > 0) {
                    [self showContentView:YES];
                } else {
                    [self hideContentView:YES];
                }
            } else {
                // Move the background view by the dX / dY respectively
                CGRect backgroundFrame = [self backgroundViewFrame];
                CGFloat fullWidth = self.bounds.size.width - self.indicatorSize.width;
                CGFloat fullHeight = self.bounds.size.height - self.indicatorSize.height;
                CGFloat fraction = 0;
                
                if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight) {
                    fraction = 1 - ((backgroundFrame.origin.x + dX) / fullWidth);
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
                    fraction = 1 - ((backgroundFrame.origin.y + dY) / fullHeight);
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
                    fraction = (backgroundFrame.origin.x + backgroundFrame.size.width - self.indicatorSize.width + dX) / fullWidth;
                } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
                    fraction = (backgroundFrame.origin.y + backgroundFrame.size.height - self.indicatorSize.height + dY) / fullHeight;
                }
                
                fraction = MIN(MAX(0, fraction), 1);
                
                //CGFloat reducedHeight = [self backgroundViewFrameForState:NO].size.height;
                //_backgroundView.frameX = MAX(0, backgroundFrame.origin.x + dX);
                //_backgroundView.frameHeight = reducedHeight + (fraction * (self.boundsHeight - reducedHeight));
                
                _backgroundView.frame = [self backgroundViewFrameForPercentage:fraction];
                
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
    
    if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight) {
        frame.size.width -= self.indicatorSize.width;
        frame.origin.x = _backgroundView.bounds.origin.x + self.indicatorSize.width;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
        frame.size.width -= self.indicatorSize.width;
        frame.origin.x = _backgroundView.bounds.origin.x;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
        frame.size.height -= self.indicatorSize.height;
        frame.origin.y = _backgroundView.bounds.origin.y;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
        frame.size.height -= self.indicatorSize.height;
        frame.origin.y = _backgroundView.bounds.origin.y + self.indicatorSize.height;
    }
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
    if (!active) {
        // Check where the offset background view should go
        if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight) {
            frame.origin.x = frame.origin.x + frame.size.width - self.indicatorSize.width;
        } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
            frame.origin.x = frame.origin.x + self.indicatorSize.width - frame.size.width;
        } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
            frame.origin.y = frame.origin.y + self.indicatorSize.height - frame.size.height;
        } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
            frame.origin.y = frame.origin.y + frame.size.height - self.indicatorSize.height;
        }
        return frame;
    }
    return frame;
}

- (CGRect)backgroundViewFrameForPercentage:(CGFloat)percentage
{
    CGRect hiddenFrame = [self backgroundViewFrameForState:NO];
    CGRect showingFrame = [self backgroundViewFrameForState:YES];
    CGRect backgroundViewFrame = hiddenFrame;
    
    // Interpolate between those two depending on orientation
    if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight) {
        backgroundViewFrame.origin.x = (1 - percentage) * (hiddenFrame.origin.x - showingFrame.origin.x) + showingFrame.origin.x;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
        backgroundViewFrame.origin.x = (1 - percentage) * (hiddenFrame.origin.x - showingFrame.origin.x) + showingFrame.origin.x;//percentage * (showingFrame.origin.x - hiddenFrame.origin.x) + hiddenFrame.origin.x;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
        backgroundViewFrame.origin.y = (1 - percentage) * (hiddenFrame.origin.y - showingFrame.origin.y) + showingFrame.origin.y;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
        backgroundViewFrame.origin.y = (1 - percentage) * (hiddenFrame.origin.y - showingFrame.origin.y) + showingFrame.origin.y;
    }
    return backgroundViewFrame;
}


- (CGRect)indicatorFrame
{
    CGRect frame;
    frame.size = self.indicatorSize;
    if (self.indicatorLocation == FAPushoverViewIndicatorLocationRight || self.indicatorLocation == FAPushoverViewIndicatorLocationBottom) {
        frame.origin = _backgroundView.bounds.origin;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationLeft) {
        frame.origin = _backgroundView.bounds.origin;
        frame.origin.x += _backgroundView.bounds.size.width - frame.size.width;
    } else if (self.indicatorLocation == FAPushoverViewIndicatorLocationTop) {
        frame.origin = _backgroundView.bounds.origin;
        frame.origin.y += _backgroundView.bounds.size.height - frame.size.height;
    }
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
    if (self.indicatorSize.width == 0)  {
        CGSize indicatorSize = self.indicatorSize;
        indicatorSize.width = rect.size.width;
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
