//
//  FAScrollViewWithTopView.m
//  Trakr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAScrollViewWithTopView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+FrameAdditions.h"
#import "UIFunctions.h"
#import "NSObject+PerformBlock.h"

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
    
    CGFloat _topViewOffset;
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
    _viewFrame = topView.frame;
    _overlap = overlap;
    CGSize contentSize = self.contentSize;
    CGFloat topViewHeight = topView.frame.size.height;
    _topViewOffset = - topViewHeight + overlap;
    
    CGFloat backViewOffset = 0;
    
    if (_presentedBackView) {
        backViewOffset = _backViewFrame.size.height;
    }
    
    CGRect newTopViewFrame = CGRectMake(0, - topViewHeight + backViewOffset, contentSize.width, topViewHeight);
    topView.frame = newTopViewFrame;
    
    [self.topViewContentView insertSubview:topView atIndex:0];
    [self.topViewContentView insertSubview:backgroundView belowSubview:topView];
    backgroundView.frameY += backViewOffset;
    [self.topViewContentView insertSubview:_hoverView aboveSubview:topView];
    _hoverView.hidden = NO;
    
    CGFloat initialContentOffset = self.contentOffset.y;
    
    [self setTopViewContentViewFrame];
    
    CGRect intermediateFrame = CGRectMake(0, _topViewOffset, contentSize.width, topViewHeight);
    if (_presentedBackView) {
        intermediateFrame.origin.y += _backViewFrame.size.height;
    }
    _hoverView.frameY = - topViewHeight + backViewOffset;
    
    CGRect hoverViewIntermediateFrame = _hoverView.frame;
    hoverViewIntermediateFrame.origin.y = _topViewOffset;
    
    CGRect finalFrame = CGRectMake(0, 0, contentSize.width, topViewHeight);
    finalFrame.origin.y += backViewOffset;
    
    _topViewContentInsets = UIEdgeInsetsMake(finalFrame.size.height - overlap, 0, 0, 0);
    CGFloat top = finalFrame.size.height - overlap - self.contentOffset.y;
    
    UIEdgeInsets topViewContentInsets = _topViewContentInsets;
    if (_presentedBackView) {
        topViewContentInsets = UIEdgeInsetsAdd(topViewContentInsets, _backViewContentInsets);
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
            _hoverView.frameY = intermediateFrame.origin.y;
        } completion:^(BOOL finished) {
            CGFloat difference = _topViewOffset - backViewOffset - self.topViewContentView.frameY;
            [self setTopViewContentViewFrameToOffset:CGPointMake(0, _topViewOffset - backViewOffset)];
            if (_backView) {
                _backView.frameY = -difference;
            }
            topView.frameY = backViewOffset;
            _hoverView.frameY = backViewOffset;
            [UIView animateWithDuration:finishingDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                if (initialContentOffset > finalFrame.size.height) {
                    // We are scrolled more down than the image is high, don't scroll the contentOffset at all
                    // just blink the scrollers to indicate something happened
                    blinkScrollers = YES;
                } else {
                    // Scroll to the top
                    self.contentOffset = CGPointMake(0, -top);
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    [self setTopViewContentViewFrame];
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
        //_topViewContentView.frame = CGRectMake(0, 0, _viewFrame.size.width, _viewFrame.size.height);
        [self setTopViewContentViewFrame];
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
    [_hoverView setFrameY:0];
    if (!_topViewDisplayed) {
        hoverView.hidden = YES;
    }
    [self.topViewContentView addSubview:hoverView];
}

- (UIView *)backViewContainer
{
    return _backView;
}

- (UIView *)backView
{
    if (_backView.subviews.count == 1) {
        return _backView.subviews[0];
    }
    return nil;
}

- (void)setBackView:(UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:backView.frame];
        [self.topViewContentView insertSubview:_backView atIndex:0];
    } else {
        for (int i = 0; i < _backView.subviews.count; i++) {
            [[_backView.subviews objectAtIndex:i] removeFromSuperview];
        }
    }
    _backViewFrame = backView.frame;
    [_backView setFrameHeight:0];
    [_backView setNeedsDisplay];
    _backView.clipsToBounds = YES;
    [_backView insertSubview:backView atIndex:0];
    if (_presentedBackView) {
        [self presentBackView:NO];
    }
}

- (void)presentBackView:(BOOL)animated
{
    if (!_presentingBackView && !_presentedBackView) {
        if (animated) {
            self.showsVerticalScrollIndicator = NO;
            self.userInteractionEnabled = NO;
            _presentingBackView = YES;
            self.bounces = NO;
            
            CGPoint contentOffset = CGPointMake(0, _topViewOffset - self.backView.frameHeight);
            CGFloat difference = contentOffset.y - self.topViewContentView.frameY;
            
            [self setTopViewContentViewFrameToOffset:contentOffset];
            [_hoverView setFrameY:self.backView.frameHeight];
            [_topView setFrameY:self.backView.frameHeight];
            [_backView setFrameY:-difference];
            
            //_backView.frame = CGRectMake(_backViewFrame.origin.x, self.contentOffset.y, _backViewFrame.size.width, _backViewFrame.size.height);
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                CGFloat contentOffsetY = -_backViewFrame.size.height + _topViewOffset;
                //NSLog(@"Will set contentOffset to %f", contentOffsetY);
                self.contentOffset = CGPointMake(0, contentOffsetY);
            } completion:^(BOOL finished) {
                _presentingBackView = NO;
                _presentedBackView = YES;
                self.bounces = YES;
                CGFloat bottomInset = self.contentSize.height - self.frame.size.height + _backViewFrame.size.height;
                _backViewContentInsets = UIEdgeInsetsMake(_backViewFrame.size.height, 0, -bottomInset, 0);
                UIEdgeInsets newEdgeInsets = UIEdgeInsetsAdd(_topViewContentInsets, _backViewContentInsets);
                self.contentInset = newEdgeInsets;
                self.userInteractionEnabled = YES;
            }];
        } else {
            CGFloat contentOffsetY = -_backViewFrame.size.height + _topViewOffset;
            //NSLog(@"Will set contentOffset to %f", contentOffsetY);
            self.contentOffset = CGPointMake(0, contentOffsetY);
            _presentedBackView = YES;
            self.bounces = YES;
            CGFloat oldInset = _topViewContentInsets.top;
            CGFloat bottomInset = self.contentSize.height - self.frame.size.height + oldInset + _backViewFrame.size.height;
            _backViewContentInsets = UIEdgeInsetsMake(oldInset + _backViewFrame.size.height, 0, -bottomInset, 0);
            self.contentInset = _backViewContentInsets;
            
            [self setContentOffset:self.contentOffset];
            
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
            
            CGPoint contentOffset = CGPointMake(0, _topViewOffset);
            CGFloat difference = contentOffset.y - self.topViewContentView.frameY;
            
            [self setTopViewContentViewFrameToOffset:contentOffset];
            [_hoverView setFrameY:0];
            [_topView setFrameY:0];
            [_backView setFrameY:-difference];
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
                self.contentOffset = contentOffset;
            } completion:^(BOOL finished) {
                _hidingBackView = NO;
                //CGFloat oldInset = _topViewContentInsets.top;
                //self.contentInset = UIEdgeInsetsMake(oldInset, 0, 0, 0);
                self.contentInset = _topViewContentInsets;
                self.bounces = YES;
                self.showsVerticalScrollIndicator = YES;
                [self setContentOffset:CGPointMake(0, _topViewOffset) animated:NO];
            }];
        } else {
            _presentedBackView = NO;
            self.contentOffset = CGPointMake(0, _topViewOffset);
            CGFloat oldInset = _topViewContentInsets.top;
            self.contentInset = UIEdgeInsetsMake(oldInset, 0, 0, 0);
            self.showsVerticalScrollIndicator = YES;
            [self setContentOffset:CGPointMake(0, _topViewOffset) animated:NO];
        }
    }
}

- (void)setTopViewContentViewFrame
{
    [self setTopViewContentViewFrameToOffset:self.contentOffset];
}

- (void)setTopViewContentViewFrameToOffset:(CGPoint)offset
{
    CGRect topViewContentViewFrame = self.topViewContentView.frame;
    topViewContentViewFrame.origin.x = offset.x;
    topViewContentViewFrame.origin.y = offset.y;
    topViewContentViewFrame.size.height = -offset.y;
    topViewContentViewFrame.size.width = self.frame.size.width;
    self.topViewContentView.frame = topViewContentViewFrame;
}
/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitTest = [super hitTest:point withEvent:event];
    NSLog(@"HitTest for location: %fx%f returned view: %@", point.x, point.y, hitTest);
    return hitTest;
}*/

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (_presentingBackView) {
        //NSLog(@"removing bouncing");
        contentOffset.y = - _backViewFrame.size.height + _topViewOffset;
    }
    
    [super setContentOffset:contentOffset];
    
    if (_topViewDisplayed || _backView) {
        if (_topViewContentView) {
            [self setTopViewContentViewFrame];
        }
        
        CGFloat normalizedContentOffset = contentOffset.y - _topViewOffset;
        //NSLog(@"NormalizedContentOffset: %f", normalizedContentOffset);
        
        CGFloat viewWidth = self.frame.size.width;
        
        CGFloat scale = (MAX(_viewFrame.size.height, _viewFrame.size.height - normalizedContentOffset) / _viewFrame.size.height);
        
        FAScrollViewWithTopViewAnimationStyle topViewAnimationStyle = self.topViewAnimationStyle;
        
        if (_backView) {
            topViewAnimationStyle = FAScrollViewWithTopViewAnimationStyleNone;
            CGFloat backViewX, backViewY, backViewWidth, backViewHeight;
            CGFloat bwOffset = self.contentOffset.y;
            backViewWidth = viewWidth;
            backViewX = 0;
            backViewY = 0;
            //backViewHeight = _backViewFrame.size.height;
            backViewHeight = MAX(0, - normalizedContentOffset);
            //NSLog(@"backViewHeight:%f", backViewHeight);
            _backView.frame = CGRectMake(backViewX, backViewY, backViewWidth, backViewHeight);
            [_backView setNeedsDisplay];
        }
        
        CGFloat x, y, width, height;
        
        if (topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleZoom) {
            width = viewWidth * scale;
            x = (viewWidth - width) / 2;
            y = MIN(contentOffset.y, _topViewOffset) - contentOffset.y;
            height = MAX(- normalizedContentOffset + _viewFrame.size.height, _viewFrame.size.height);
        } else if (topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleCenter) {
            width = viewWidth;
            x = 0;
            y = MIN( (_topViewOffset + contentOffset.y) / 2, _topViewOffset) - contentOffset.y;
            height = _viewFrame.size.height;
        } else {
            width = viewWidth;
            x = 0;
            y = MAX(- normalizedContentOffset, _topViewOffset);
            height = _viewFrame.size.height;
            if (_backView) {
                if (normalizedContentOffset < 0) {
                    self.scrollIndicatorInsets = UIEdgeInsetsMake(-normalizedContentOffset, 0, 0, 0);
                } else {
                    self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
        }
        
        DDLogView(@"contentOffset: %f, normalized: %f, y: %f", contentOffset.y, normalizedContentOffset, y);
        
        if (_hoverView) {
            [_hoverView setFrameY:y];
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
