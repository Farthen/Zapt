//
//  FAAppDelegate.h
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)performInitialLogin:(id)sender;
- (void)performLoginIfRequired:(id)sender animated:(BOOL)animated;
- (void)handleNetworkNotAvailable;
- (void)handleInvalidCredentials;
- (void)handleTimeout;

@end
