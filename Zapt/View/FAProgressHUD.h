//
//  FAProgressHUD.h
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAProgressHUD : NSObject

@property (retain) NSArray *disabledUIElements;

- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithRootView;

- (void)showProgressHUDSuccess;
- (void)showProgressHUDSuccessMessage:(NSString *)message;

- (void)showProgressHUDFailed;
- (void)showProgressHUDFailedMessage:(NSString *)message;

- (void)showProgressHUDSpinner;
- (void)showProgressHUDSpinnerWithText:(NSString *)text;

- (void)hideProgressHUD;

@end
