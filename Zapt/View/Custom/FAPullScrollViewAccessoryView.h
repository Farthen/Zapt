//
//  FAPullScrollViewAccessoryView.h
//  Zapt
//
//  Created by Finn Wilke on 13/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FAPullScrollViewAccessoryView;

@protocol FAPullScrollViewAccessoryViewDelegate <NSObject>

@optional
- (void)pullScrollViewAccessoryViewBeganPulling:(FAPullScrollViewAccessoryView *)accessoryView;
- (void)pullScrollViewAccessoryView:(FAPullScrollViewAccessoryView *)accessoryView endedPullingSuccessfully:(BOOL)success;

@end


@interface FAPullScrollViewAccessoryView : UIView

- (void)addToScrollView:(UIScrollView *)scrollView bottom:(BOOL)bottom;

@property (nonatomic, readonly) UILabel *textLabel;

@property (nonatomic, weak) id<FAPullScrollViewAccessoryViewDelegate> delegate;

@end
