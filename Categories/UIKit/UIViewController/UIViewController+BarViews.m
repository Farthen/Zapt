//
//  UIViewController+ToolbarView.m
//  Zapt
//
//  Created by Finn Wilke on 14/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "UIViewController+BarViews.h"

@implementation UIViewController (BarViews)

- (UIToolbar *)toolbarView
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIToolbar class]]) {
            return (UIToolbar *)view;
        }
    }
    
    return nil;
}

@end
