//
//  FAScrollViewWithTopView.h
//  Trakr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAScrollViewWithTopView : UIScrollView

typedef enum {
    FAScrollViewWithTopViewAnimationStyleZoom = 0,
    FAScrollViewWithTopViewAnimationStyleCenter = 1,
    FAScrollViewWithTopViewAnimationStyleNone = 2,
} FAScrollViewWithTopViewAnimationStyle;

@property (retain) IBOutlet UIView *contentView;
@property (readonly) UIView *topViewContentView;
@property (readonly) UIView *topView;
@property (retain) UIView *backView;
@property (readonly) UIView *backViewContainer;
@property (retain) UIView *hoverView;
@property (assign) FAScrollViewWithTopViewAnimationStyle topViewAnimationStyle;

- (void)presentBackView:(BOOL)animated;
- (void)hideBackView:(BOOL)animated;
- (void)presentTopView:(UIView *)topView withBackgroundView:(UIView *)backgroundView overlapping:(CGFloat)overlap animated:(BOOL)animated;

@end
