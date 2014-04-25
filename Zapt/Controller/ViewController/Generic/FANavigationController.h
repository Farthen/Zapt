//
//  FANavigationController.h
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FASlideAnimatedTransition.h"

extern NSString *const FANavigationControllerDidPopToRootViewControllerNotification;

@protocol FANavigationControllerLongButtonTouchDelegate <UINavigationControllerDelegate>
@optional
- (BOOL)navigationController:(UINavigationController *)navigationController shouldPopToRootViewControllerAfterLongButtonTouchForViewController:(UIViewController *)viewController;
- (void)navigationController:(UINavigationController *)navigationController didPopToRootViewControllerAfterLongButtonTouchForViewController:(UIViewController *)viewController;
@end

@interface FANavigationController : UINavigationController <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

- (void)addLongButtonTouchGesture;
- (void)replaceTopViewControllerWithViewController:(UIViewController *)viewController usingSlideAnimation:(BOOL)animated direction:(FASlideAnimatedTransitionDirection)direction completion:(void (^)(void))completion;

@end
