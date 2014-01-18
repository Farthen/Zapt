//
//  FAAdaptiveNavigationBar.m
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAAdaptiveNavigationBar.h"

@implementation FAAdaptiveNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}

/*
 - (UIBarPosition)barPosition
 {
 return UIBarPositionTopAttached;
 }*/


- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    intrinsicContentSize.height += [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    return intrinsicContentSize;
}

@end
