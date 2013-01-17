//
//  FASearchBar.m
//  Trakr
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

// Fixes radar://12901765
- (void)setShowsScopeBar:(BOOL)showsScopeBar
{
    if (self.showsScopeBar != !!showsScopeBar) [self invalidateIntrinsicContentSize];
    [super setShowsScopeBar:showsScopeBar];
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