//
//  UIView+SizeToFitSubviews.m
//  Zapr
//
//  Created by Finn Wilke on 18.12.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "UIView+SizeToFitSubviews.h"

@implementation UIView (SizeToFitSubviews)

- (void)resizeToFitSubviews
{
    [self resizeWidthToFitSubviews];
    [self resizeHeightToFitSubviews];
}

- (void)resizeToFitSubviewsWithMinimumSize:(CGSize)size
{
    [self resizeWidthToFitSubviewsWithMinimumSize:size.width];
    [self resizeHeightToFitSubviewsWithMinimumSize:size.height];
}

- (void)resizeWidthToFitSubviews
{
    [self resizeWidthToFitSubviewsWithMinimumSize:0];
}

- (void)resizeHeightToFitSubviews
{
    [self resizeHeightToFitSubviewsWithMinimumSize:0];
}

- (void)resizeWidthToFitSubviewsWithMinimumSize:(CGFloat)width
{
    CGFloat maxWidth = width - 20;
    
    for (UIView *view in self.subviews) {
        CGFloat currentWidth = view.frame.origin.x + view.frame.size.width;
        maxWidth = MAX(currentWidth, maxWidth);
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, maxWidth + 20, self.frame.size.height)];
}

- (void)resizeHeightToFitSubviewsWithMinimumSize:(CGFloat)height
{
    CGFloat maxHeight = height - 20;
    
    for (UIView *view in self.subviews) {
        CGFloat currentHeight = view.frame.origin.y + view.frame.size.height;
        maxHeight = MAX(currentHeight, maxHeight);
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, maxHeight + 20)];
}

@end
