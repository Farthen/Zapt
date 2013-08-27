//
//  FASearchBar.m
//  Zapr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASearchBar.h"

@implementation FASearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Fixes radar://12901765 - fixed in iOS 7
- (void)setShowsScopeBar:(BOOL)showsScopeBar
{
    if (self.showsScopeBar != !!showsScopeBar) [self invalidateIntrinsicContentSize];
    [super setShowsScopeBar:showsScopeBar];
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    intrinsicContentSize.width = self.superview.frame.size.width;
    return intrinsicContentSize;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
