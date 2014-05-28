//
//  FASemiModalEnabledViewController.h
//  Zapt
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAViewController.h"

@interface FASemiModalEnabledViewController : FAViewController

- (void)presentSemiModalViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissSemiModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)updateSizeForPresentedSemiModalViewControllerAnimated:(BOOL)animated;

- (void)displaySemiModalViewControllerNavigationItem;
- (void)displayContainerNavigationItem;

@end
