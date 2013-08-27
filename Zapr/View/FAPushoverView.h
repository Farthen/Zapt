//
//  FAPushoverView.h
//  Trakr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAOverlayView.h"

@interface FAPushoverView : UIView <UIGestureRecognizerDelegate>

typedef enum {
    FAPushoverViewIndicatorLocationLeft = 0,
    FAPushoverViewIndicatorLocationTop = 1,
    FAPushoverViewIndicatorLocationRight = 2,
    FAPushoverViewIndicatorLocationBottom = 3,
} FAPushoverViewIndicatorLocation;

@property (nonatomic) FAPushoverViewIndicatorLocation indicatorLocation;
@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) UIView *contentView;
@property (readonly) UIView *backgroundView;

- (CGRect)backgroundViewFrameForState:(BOOL)active;

@end

@protocol FAPushoverViewDelegate <NSObject>
@optional
- (void)pushoverView:(FAPushoverView *)pushoverView willShowContentView:(BOOL)animated;
- (void)pushoverViewDidShowContentView:(FAPushoverView *)pushoverView;
- (void)pushoverView:(FAPushoverView *)pushoverView willHideContentView:(BOOL)animated;
- (void)pushoverViewDidHideContentView:(FAPushoverView *)pushoverView;

// animation method
- (void)pushoverView:(FAPushoverView *)pushoverView isAtFractionForHeightAnimation:(CGFloat)fraction;

@end

@interface FAPushoverView (Delegate)

@property (assign) IBOutlet id<FAPushoverViewDelegate> delegate;

@end