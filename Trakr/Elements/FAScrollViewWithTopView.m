//
//  FAScrollViewWithTopView.m
//  Trakr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAScrollViewWithTopView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FAScrollViewWithTopView {
    UIView *_hoverView;
    UIView *_backView;
    UIView *_topViewContentView;
    
    BOOL _topViewDisplayed;
    BOOL _presentingTopView;
    BOOL _presentingBackView;
    BOOL _hidingBackView;
    BOOL _presentedBackView;
    CGRect _viewFrame;
    CGRect _backViewFrame;
    CGFloat _overlap;
    UIEdgeInsets _topViewContentInsets;
    UIEdgeInsets _backViewContentInsets;
}

@synthesize topView = _topView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)presentTopView:(UIView *)topView withBackgroundView:(UIView *)backgroundView overlapping:(CGFloat)overlap animated:(BOOL)animated
{
    _presentingTopView = YES;
    [_topView removeFromSuperview];
    _topView = topView;
    _topView.hidden = NO;
    _viewFrame = CGRectMake(topView.frame.origin.x, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    _overlap = overlap;
    CGSize contentSize = self.contentSize;
    CGFloat topViewHeight = topView.frame.size.height;
    
    CGRect newTopViewFrame = CGRectMake(0, - topViewHeight, contentSize.width, topViewHeight);
    topView.frame = newTopViewFrame;
    
    [self.topViewContentView insertSubview:topView atIndex:0];
    [self.topViewContentView insertSubview:backgroundView belowSubview:topView];
    [self.topViewContentView insertSubview:_hoverView aboveSubview:topView];
    _hoverView.hidden = NO;
    
    CGFloat initialContentOffset = self.contentOffset.y;
    
    CGFloat backViewOffset = 0;
    
    if (_presentedBackView) {
        initialContentOffset += _backViewFrame.size.height;
        backViewOffset = _backViewFrame.size.height;
    }
    
    CGRect intermediateFrame = CGRectMake(0, - topViewHeight + overlap, contentSize.width, topViewHeight);
    CGRect hoverViewIntermediateFrame = _hoverView.frame;
    hoverViewIntermediateFrame.origin.y = intermediateFrame.origin.y;
    _hoverView.frame = hoverViewIntermediateFrame;
    CGRect finalFrame = CGRectMake(0, -topViewHeight + overlap, contentSize.width, topViewHeight);
    CGFloat top = finalFrame.size.height - overlap;
    _topViewContentInsets = UIEdgeInsetsMake(top, 0, 0, 0);
    UIEdgeInsets topViewContentInsets = _topViewContentInsets;
    if (_presentedBackView) {
        topViewContentInsets.top += _backViewContentInsets.top;
        topViewContentInsets.left += _backViewContentInsets.left;
        topViewContentInsets.bottom += _backViewContentInsets.bottom;
        topViewContentInsets.right += _backViewContentInsets.right;
    }
        
    if (animated) {
        self.userInteractionEnabled = NO;
        NSTimeInterval animationDuration = 0.3;
        NSTimeInterval intermediateFraction = overlap / topViewHeight;
        NSTimeInterval intermediateDuration = intermediateFraction * animationDuration;
        NSTimeInterval finishingDuration = animationDuration - intermediateDuration;
        __block BOOL blinkScrollers = NO;
        
        [UIView animateWithDuration:intermediateDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
            topView.frame = intermediateFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:finishingDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                if (_hoverView) {
                    CGRect hoverViewFrame = _hoverView.frame;
                    hoverViewFrame.origin.y = finalFrame.origin.y;//MIN(self.contentOffset.y + backViewOffset, - _viewFrame.size.height + _overlap + backViewOffset);
                    _hoverView.frame = hoverViewFrame;
                }
                if (initialContentOffset > finalFrame.size.height) {
                    // We are scrolled more down than the image is high, don't scroll the contentOffset at all
                    // just blink the scrollers to indicate something happened
                    blinkScrollers = YES;
                } else {
                    // Scroll to the top
                    self.contentOffset = CGPointMake(0, -top - backViewOffset);
                }
                topView.frame = finalFrame;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.contentInset = topViewContentInsets;
                    self.userInteractionEnabled = YES;
                    backgroundView.hidden = YES;
                    if (blinkScrollers) {
                        [self flashScrollIndicators];
                    }
                    _topViewDisplayed = YES;
                    _presentingTopView = NO;
                    if (_presentedBackView) {
                        [self.topViewContentView insertSubview:_backView aboveSubview:backgroundView];
                    }
                }
            }];
        }];
    } else {
        backgroundView.hidden = YES;
        //self.contentOffset = CGPointMake(0, initialContentOffset - top);
        self.contentInset = topViewContentInsets;
        topView.frame = finalFrame;
        _topViewDisplayed = YES;
        _presentingTopView = NO;
        if (_presentedBackView) {
            [self.topViewContentView insertSubview:_backView aboveSubview:backgroundView];
        }
    }
}

- (UIView *)topViewContentView
{
    if (!_topViewContentView) {
        _topViewContentView = [[UIView alloc] initWithFrame:_viewFrame];
        _topViewContentView.frame = CGRectMake(0, 0, _viewFrame.size.width, _viewFrame.size.height);
        [self insertSubview:_topViewContentView atIndex:0];
    }
    return _topViewContentView;
}

- (UIView *)hoverView
{
    return _hoverView;
}

- (void)setHoverView:(UIView *)hoverView
{
    [_hoverView removeFromSuperview];
    _hoverView = hoverView;
    CGRect hoverViewFrame = _hoverView.frame;
    hoverViewFrame.origin.y = 0;//MIN(self.contentOffset.y, - _viewFrame.size.height + _overlap);
    if (!_topViewDisplayed) {
        hoverView.hidden = YES;
    }
    _hoverView.frame = hoverViewFrame;
    [self.topViewContentView addSubview:hoverView];
}

- (UIView *)backView
{
    return _backView;
}

- (void)setBackView:(UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:backView.frame];
        [_backView insertSubview:backView atIndex:0];
        [self.topViewContentView insertSubview:_backView atIndex:0];
    } else {
        for (int i = 0; i < _backView.subviews.count; i++) {
            [[_backView.subviews objectAtIndex:i] removeFromSuperview];
        }
    }
    _backViewFrame = backView.frame;
    _backView.frame = CGRectMake(backView.frame.origin.x, backView.frame.origin.y, backView.frame.size.width, 0);
    [_backView setNeedsDisplay];
    _backView.clipsToBounds = YES;
}

- (void)presentBackView:(BOOL)animated
{
    if (!_presentingBackView && !_presentedBackView) {
        if (animated) {
            self.showsVerticalScrollIndicator = NO;
            self.userInteractionEnabled = NO;
            _presentingBackView = YES;
            self.bounces = NO;
            //_backView.frame = CGRectMake(_backViewFrame.origin.x, self.contentOffset.y, _backViewFrame.size.width, _backViewFrame.size.height);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                CGFloat contentOffsetY = -_backViewFrame.size.height - _viewFrame.size.height + _overlap;
                //NSLog(@"Will set contentOffset to %f", contentOffsetY);
                self.contentOffset = CGPointMake(0, contentOffsetY);
            } completion:^(BOOL finished) {
                _presentingBackView = NO;
                _presentedBackView = YES;
                self.bounces = YES;
                CGFloat oldInset;
                if (_topView) {
                    oldInset = _topViewContentInsets.top;
                } else {
                    oldInset = 0;
                }
                CGFloat bottomInset = self.contentSize.height - self.frame.size.height + oldInset + _backViewFrame.size.height;
                _backViewContentInsets = UIEdgeInsetsMake(oldInset + _backViewFrame.size.height, 0, -bottomInset, 0);
                self.contentInset = _backViewContentInsets;
                self.userInteractionEnabled = YES;
            }];
        } else {
            CGFloat contentOffsetY = -_backViewFrame.size.height - _viewFrame.size.height + _overlap;
            //NSLog(@"Will set contentOffset to %f", contentOffsetY);
            self.contentOffset = CGPointMake(0, contentOffsetY);
            _presentedBackView = YES;
            self.bounces = YES;
            CGFloat oldInset = _topViewContentInsets.top;
            CGFloat bottomInset = self.contentSize.height - self.frame.size.height + oldInset + _backViewFrame.size.height;
            _backViewContentInsets = UIEdgeInsetsMake(oldInset + _backViewFrame.size.height, 0, -bottomInset, 0);
            self.contentInset = _backViewContentInsets;
            self.userInteractionEnabled = YES;
        }
    }
}

- (void)hideBackView:(BOOL)animated
{
    if (_presentedBackView) {
        if (animated) {
            CGFloat bottomInset = self.contentSize.height - self.frame.size.height + _topViewContentInsets.top;
            self.contentInset = UIEdgeInsetsMake(_topViewContentInsets.top + _backViewFrame.size.height, 0, -bottomInset, 0);
            self.bounces = NO;
            _hidingBackView = YES;
            _presentedBackView = NO;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
                self.contentOffset = CGPointMake(0, - _viewFrame.size.height + _overlap);
            } completion:^(BOOL finished) {
                _hidingBackView = NO;
                CGFloat oldInset = _topViewContentInsets.top;
                self.contentInset = UIEdgeInsetsMake(oldInset, 0, 0, 0);
                self.bounces = YES;
                self.showsVerticalScrollIndicator = YES;
                [self setContentOffset:CGPointMake(0, - _viewFrame.size.height + _overlap) animated:NO];
            }];
        } else {
            CGFloat oldInset = _topViewContentInsets.top;
            self.contentInset = UIEdgeInsetsMake(oldInset, 0, 0, 0);
            self.showsVerticalScrollIndicator = YES;
            [self setContentOffset:CGPointMake(0, - _viewFrame.size.height + _overlap) animated:NO];
        }
    }
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (_presentingBackView) {
        //NSLog(@"removing bouncing");
        contentOffset.y = - _backViewFrame.size.height - _viewFrame.size.height + _overlap;
    }
        
    //NSLog(@"Setting contentOffset from %f to %f", self.contentOffset.y, contentOffset.y);
    
    [super setContentOffset:contentOffset];
    
    if (_topViewDisplayed || _backView) {
        CGFloat normalizedContentOffset = contentOffset.y + _viewFrame.size.height - _overlap;
        //NSLog(@"NormalizedContentOffset: %f", normalizedContentOffset);
        
        CGFloat viewWidth = self.frame.size.width;
        
        CGFloat scale = (MAX(_viewFrame.size.height, _viewFrame.size.height - normalizedContentOffset) / _viewFrame.size.height);
        
        FAScrollViewWithTopViewAnimationStyle topViewAnimationStyle = self.topViewAnimationStyle;
        
        if (_backView) {
            topViewAnimationStyle = FAScrollViewWithTopViewAnimationStyleNone;
            CGFloat backViewX, backViewY, backViewWidth, backViewHeight;
            CGFloat bwOffset = contentOffset.y;
            backViewWidth = viewWidth;
            backViewX = 0;
            if (_presentedBackView || _hidingBackView) {
                backViewY = MAX(bwOffset, bwOffset - ((normalizedContentOffset + _backViewFrame.size.height) / 2));
                //NSLog(@"Setting backViewY: %f", backViewY);
            } else {
                backViewY = bwOffset;
            }
            //NSLog(@"backviewy: %f, contentOffset:%f", backViewY, normalizedContentOffset);
            backViewHeight = _backViewFrame.size.height;
            backViewHeight = MAX(0, - normalizedContentOffset);
            //NSLog(@"backViewHeight:%f", backViewHeight);
            _backView.frame = CGRectMake(backViewX, backViewY, backViewWidth, backViewHeight);
            [_backView setNeedsDisplay];
        }
        
        CGFloat x, y, width, height;
        
        if (topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleZoom) {
            width = viewWidth * scale;
            x = (viewWidth - width) / 2;
            y = MIN(contentOffset.y, - _viewFrame.size.height + _overlap);
            height = MAX(- normalizedContentOffset + _viewFrame.size.height, _viewFrame.size.height);
        } else if (topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleCenter) {
            width = viewWidth;
            x = 0;
            y = MIN( - (_viewFrame.size.height - contentOffset.y - _overlap) / 2, - _viewFrame.size.height + _overlap);
            height = _viewFrame.size.height;
        } else {
            width = viewWidth;
            x = 0;
            y = - _viewFrame.size.height + _overlap;
            height = _viewFrame.size.height;
            if (_backView) {
                if (normalizedContentOffset < 0) {
                    self.scrollIndicatorInsets = UIEdgeInsetsMake(-normalizedContentOffset, 0, 0, 0);
                } else {
                    self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
        }
        
        if (_hoverView && _topViewDisplayed) {
            CGRect hoverViewFrame = _hoverView.frame;
            if (self.topViewAnimationStyle != FAScrollViewWithTopViewAnimationStyleNone) {
                hoverViewFrame.origin.y = MIN(contentOffset.y, - _viewFrame.size.height + _overlap);
            } else {
                hoverViewFrame.origin.y = - _viewFrame.size.height + _overlap;
            }
            _hoverView.frame = hoverViewFrame;
        }
        
        
        CGRect newFrame = CGRectMake(x, y, width, height);
        
        //NSLog(@"setting frame to: %fx%f size: %fx%f", newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
        _topView.frame = newFrame;
        
        if (!_presentingTopView) {
            if (normalizedContentOffset < -50) {
                if (!self.decelerating) {
                    if (_backView && !_presentedBackView && !_hidingBackView && !_presentingBackView) {
                        [self presentBackView:YES];
                        return;
                    }
                }
            }
            
            if (_presentedBackView && !_hidingBackView) {
                if (normalizedContentOffset + _backViewFrame.size.height > 30) {
                    [self hideBackView:YES];
                }
            }
        }
    }
}

@end
