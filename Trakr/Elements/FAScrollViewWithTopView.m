//
//  FAScrollViewWithTopView.m
//  Trakr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAScrollViewWithTopView.h"

@implementation FAScrollViewWithTopView {
    UIView *_hoverView;
    UIView *_topViewContentView;
    
    BOOL _topViewDisplayed;
    CGRect _viewFrame;
    CGFloat _overlap;
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
    [_topView removeFromSuperview];
    _topView = topView;
    _viewFrame = CGRectMake(topView.frame.origin.x, topView.frame.origin.y, topView.frame.size.width, topView.frame.size.height);
    _overlap = overlap;
    CGSize contentSize = self.contentSize;
    CGFloat topViewHeight = topView.frame.size.height;
    
    CGRect newTopViewFrame = CGRectMake(0, - topViewHeight, contentSize.width, topViewHeight);
    topView.frame = newTopViewFrame;
    
    [self.topViewContentView insertSubview:topView atIndex:0];
    [self.topViewContentView insertSubview:backgroundView belowSubview:topView];
    
    CGFloat initialContentOffset = self.contentOffset.y;
    
    CGRect intermediateFrame = CGRectMake(0, - initialContentOffset - topViewHeight + overlap, contentSize.width, topViewHeight);
    CGRect finalFrame = CGRectMake(0, -topViewHeight + overlap, contentSize.width, topViewHeight);
    CGFloat top = finalFrame.size.height - overlap;
    
    if (animated) {
        self.userInteractionEnabled = NO;
        CGFloat animationDuration = 0.3;
        CGFloat intermediateFraction = overlap / topViewHeight;
        CGFloat intermediateDuration = intermediateFraction * animationDuration;
        CGFloat finishingDuration = animationDuration - intermediateDuration;
        __block BOOL blinkScrollers = NO;
        
        [UIView animateWithDuration:intermediateDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
            topView.frame = intermediateFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:finishingDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
                self.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
                if (_hoverView) {
                    CGRect hoverViewFrame = _hoverView.frame;
                    hoverViewFrame.origin.y = MIN(self.contentOffset.y, - _viewFrame.size.height + _overlap);
                    _hoverView.frame = hoverViewFrame;
                }
                if (initialContentOffset > finalFrame.size.height) {
                    // We are scrolled more down than the image is high, don't scroll the contentOffset at all
                    // just blink the scrollers to indicate something happened
                    blinkScrollers = YES;
                } else {
                    // Scroll to the top
                    self.contentOffset = CGPointMake(0, -top);
                }
                topView.frame = finalFrame;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.userInteractionEnabled = YES;
                    backgroundView.hidden = YES;
                    if (blinkScrollers) {
                        [self flashScrollIndicators];
                    }
                    _topViewDisplayed = YES;
                }
            }];
        }];
    } else {
        backgroundView.hidden = YES;
        //self.contentOffset = CGPointMake(0, initialContentOffset - top);
        self.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
        topView.frame = finalFrame;
        _topViewDisplayed = YES;
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
    _hoverView.frame = hoverViewFrame;
    [self.topViewContentView addSubview:hoverView];
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (_topViewDisplayed) {
        CGFloat offset = contentOffset.y + _viewFrame.size.height - _overlap;
        
        CGFloat viewWidth = self.frame.size.width;
        
        CGFloat scale = (MAX(_viewFrame.size.height, _viewFrame.size.height - offset) / _viewFrame.size.height);
        
        /*if (-offset < _topView.frame.size.height) {
            scale = 1;
        }*/
        
        CGFloat x, y, width, height;
        
        if (self.topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleZoom) {
            width = viewWidth * scale;
            x = (viewWidth - width) / 2;
            y = MIN(contentOffset.y, - _viewFrame.size.height + _overlap);
            height = MAX(- offset + _viewFrame.size.height, _viewFrame.size.height);
        } else if (self.topViewAnimationStyle == FAScrollViewWithTopViewAnimationStyleCenter) {
            width = viewWidth;
            x = 0;
            y = MIN( - (_viewFrame.size.height - contentOffset.y - _overlap) / 2, - _viewFrame.size.height + _overlap);
            height = _viewFrame.size.height;
        } else {
            width = viewWidth;
            x = 0;
            y = - _viewFrame.size.height + _overlap;
            height = _viewFrame.size.height;
        }
        
        if (_hoverView) {
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
    }
    
    [super setContentOffset:contentOffset];
}

@end
