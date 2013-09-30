//
//  UIViewController+PresentInsideNavigationController.h
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PresentInsideNavigationController)

- (void)presentViewControllerInsideNavigationController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;

@end
