//
//  FAAppDelegate.h
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATraktConnectionResponse.h"

@protocol FAViewControllerPreferredContentSizeChanged <NSObject>
- (void)preferredContentSizeChanged;
@end

@interface FAAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL authViewShowing;
@property UIColor *tintColor;

- (void)showNeedsLoginAlertWithActionName:(NSString *)actionName;
- (void)performLoginAnimated:(BOOL)animated;
- (void)handleConnectionErrorResponse:(FATraktConnectionResponse *)response;
- (void)handleTimeout;
- (void)handleInvalidCredentials;

@end
