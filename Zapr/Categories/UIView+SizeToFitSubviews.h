//
//  UIView+SizeToFitSubviews.h
//  Zapr
//
//  Created by Finn Wilke on 18.12.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SizeToFitSubviews)

- (void)resizeToFitSubviews;
- (void)resizeToFitSubviewsWithMinimumSize:(CGSize)size;
- (void)resizeWidthToFitSubviews;
- (void)resizeWidthToFitSubviewsWithMinimumSize:(CGFloat)width;
- (void)resizeHeightToFitSubviews;
- (void)resizeHeightToFitSubviewsWithMinimumSize:(CGFloat)height;

@end
