//
//  UIView+RecursiveSubviews.m
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+RecursiveSubviews.h"

@implementation UIView (RecursiveSubviews)

- (NSArray *)recursiveSubviews
{
    NSMutableArray *subviews = [[NSMutableArray alloc] initWithArray:self.subviews];
    for (UIView *subview in self.subviews) {
        [subviews addObjectsFromArray:[subview recursiveSubviews]];
    }
    return subviews;
}

@end
