//
//  UIViewController+PresentInsideNavigationController.m
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIViewController+PresentInsideNavigationController.h"

@implementation UIViewController (PresentInsideNavigationController)

- (void)presentViewControllerInsideNavigationController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
    [self presentViewController:navigationController animated:flag completion:completion];
}

- (UINavigationController *)wrapInsideNavigationController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    return navigationController;
}

@end
