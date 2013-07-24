//
//  FAPushoverView.h
//  Trakr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAPushoverView : UIView

@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) UIView *contentView;

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