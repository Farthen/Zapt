//
//  UIViewController+PresentInsideNavigationController.m
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIViewController+PresentInsideNavigationController.h"
#import "FANavigationController.h"

@implementation UIViewController (PresentInsideNavigationController)

- (void)presentViewControllerInsideNavigationController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    UINavigationController *navigationController = [[FANavigationController alloc] initWithRootViewController:viewControllerToPresent];
    [self presentViewController:navigationController animated:flag completion:completion];
}

- (UINavigationController *)wrapInsideNavigationController
{
    UINavigationController *navigationController = [[FANavigationController alloc] initWithRootViewController:self];
    return navigationController;
}

@end
