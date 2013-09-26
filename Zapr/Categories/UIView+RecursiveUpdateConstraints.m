//
//  UIView+RecursiveUpdateConstraints.m
//  Zapr
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+RecursiveUpdateConstraints.h"

@implementation UIView (RecursiveUpdate)

// Does the same as updateConstraints but calls it on all subviews
- (void)recursiveSetNeedsUpdateConstraints
{
    [self setNeedsUpdateConstraints];
    for (id view in self.subviews) {
        if ([view respondsToSelector:@selector(recursiveSetNeedsUpdateConstraints)]) {
            [view recursiveSetNeedsUpdateConstraints];
        } else if ([view respondsToSelector:@selector(setNeedsUpdateConstraints)]) {
            [view setNeedsUpdateConstraints];
        }
    }
}

- (void)recursiveSetNeedsLayout
{
    [self setNeedsLayout];
    for (id view in self.subviews) {
        if ([view respondsToSelector:@selector(recursiveSetNeedsLayout)]) {
            [view recursiveSetNeedsUpdateConstraints];
        } else if ([view respondsToSelector:@selector(setNeedsLayout)]) {
            [view setNeedsUpdateConstraints];
        }
    }
}

- (void)recursiveLayoutIfNeeded
{
    [self layoutIfNeeded];
    for (id view in self.subviews) {
        if ([view respondsToSelector:@selector(recursiveLayoutIfNeeded)]) {
            [view recursiveSetNeedsUpdateConstraints];
        } else if ([view respondsToSelector:@selector(layoutIfNeeded)]) {
            [view setNeedsUpdateConstraints];
        }
    }
}

@end
