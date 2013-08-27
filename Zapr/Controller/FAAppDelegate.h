//
//  FAAppDelegate.h
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL authViewShowing;

- (void)performLoginAnimated:(BOOL)animated;
- (void)handleNetworkNotAvailable;
- (void)handleOverCapacity;
- (void)handleInvalidCredentials;
- (void)handleTimeout;

@end
