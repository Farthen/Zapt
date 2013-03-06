//
//  FAProgressHUD.h
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAProgressHUD : NSObject

@property (retain) NSArray *disabledUIElements;

- (id)initWithView:(UIView *)view;
- (void)showProgressHUDSuccess;
- (void)showProgressHUDSuccessMessage:(NSString *)message;
- (void)showProgressHUDFailed;
- (void)showProgressHUDFailedMessage:(NSString *)message;
- (void)hideProgressHUD;
- (void)showProgressHUDSpinner;
- (void)showProgressHUDSpinnerWithText:(NSString *)text;

@end
