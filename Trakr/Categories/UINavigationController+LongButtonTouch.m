//
//  UINavigationController+LongButtonTouch.m
//  Trakr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UINavigationController+LongButtonTouch.h"

@protocol FANavigationControllerLongButtonTouchDelegate <UINavigationControllerDelegate>
- (BOOL)navigationController:(UINavigationController *)navigationController shouldPopToRootViewControllerAfterLongButtonTouchForViewController:(UIViewController *)viewController;
@end

@implementation UINavigationController (LongButtonTouch)

// stolen from http://stackoverflow.com/a/10005594/1084385
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // set a default rectangle in case we don't find the back button for some reason
        CGRect rect = CGRectMake(0, 0, 100, 40);
        
        // iterate through the subviews looking for something that looks like it might be the right location to be the back button
        for (UIView *subview in self.navigationBar.subviews)
        {
            if (subview.frame.origin.x < 30 && subview.frame.size.width < 300 && subview.frame.size.width > 15)
            {
                rect = subview.frame;
                break;
            }
        }
        
        // ok, let's get the point of the long press
        CGPoint longPressPoint = [sender locationInView:self.navigationBar];
        
        // if the long press point in the rectangle then do whatever
        if (CGRectContainsPoint(rect, longPressPoint)) {
            BOOL pop = YES;
            
            // Check if the delegate wants to have a say in this
            if ([self.delegate conformsToProtocol:@protocol(FANavigationControllerLongButtonTouchDelegate)]) {
                id <FANavigationControllerLongButtonTouchDelegate> __weak delegate = (id <FANavigationControllerLongButtonTouchDelegate>)self.delegate;
                if ([delegate respondsToSelector:@selector(navigationController:shouldPopToRootViewControllerAfterLongButtonTouchForViewController:)]) {
                    pop = [delegate navigationController:self shouldPopToRootViewControllerAfterLongButtonTouchForViewController:self.viewControllers.lastObject];
                }
            }
            if (pop) {
                [self popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)addLongButtonTouchGesture
{
    if (NSClassFromString(@"UILongPressGestureRecognizer"))
    {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.7;
        [self.navigationBar addGestureRecognizer:longPress];
    }
}

@end
