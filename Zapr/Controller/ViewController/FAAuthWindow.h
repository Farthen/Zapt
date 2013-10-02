//
//  FAAuthWindow.h
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FAAuthViewController;

@interface FAAuthWindow : UIWindow

+ (instancetype)window;

@property FAAuthViewController *authViewController;

- (void)showIfNeededAnimated:(BOOL)animated withInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt completion:(void (^)(void))completion;
- (void)hideAnimated:(BOOL)animated;

@end
