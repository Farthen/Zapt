//
//  FANavigationController.h
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FANavigationControllerDidPopToRootViewControllerNotification;

@protocol FANavigationControllerLongButtonTouchDelegate <UINavigationControllerDelegate>
@optional
- (BOOL)navigationController:(UINavigationController *)navigationController shouldPopToRootViewControllerAfterLongButtonTouchForViewController:(UIViewController *)viewController;
- (void)navigationController:(UINavigationController *)navigationController didPopToRootViewControllerAfterLongButtonTouchForViewController:(UIViewController *)viewController;
@end

@interface FANavigationController : UINavigationController

- (void)addLongButtonTouchGesture;

@end
