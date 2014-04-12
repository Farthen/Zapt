//
//  FAProgressHUD.m
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAProgressHUD.h"
#import "MBProgressHUD.h"

@implementation FAProgressHUD {
    MBProgressHUD *_progressHUD;
    UIImageView *_successView;
    UIImageView *_failedView;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    
    if (self) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:view];
        _successView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
        _failedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"X-Mark"]];
        _progressHUD.animationType = MBProgressHUDAnimationFade;
        [view addSubview:_progressHUD];
    }
    
    return self;
}

- (instancetype)initWithRootView
{
    UIView *view = UIWindow.mainWindow.rootViewController.view;
    return [self initWithView:view];
}

- (void)showProgressHUDSuccess
{
    [self showProgressHUDSuccessMessage:NSLocalizedString(@"Success", nil)];
}

- (void)showProgressHUDSuccessMessage:(NSString *)message
{
    _progressHUD.customView = _successView;
    [self showProgressHUDCompleteMessage:message];
}

- (void)showProgressHUDFailed
{
    [self showProgressHUDFailedMessage:NSLocalizedString(@"Failed", nil)];
}

- (void)showProgressHUDFailedMessage:(NSString *)message
{
    _progressHUD.customView = _failedView;
    [self showProgressHUDCompleteMessage:message];
}

- (void)showProgressHUDCompleteMessage:(NSString *)message
{
    if (message) {
        if (_progressHUD.isHidden) {
            [_progressHUD show:YES];
        }
        
        _progressHUD.labelText = message;
        _progressHUD.mode = MBProgressHUDModeCustomView;
        [_progressHUD hide:YES afterDelay:1];
    } else {
        [_progressHUD hide:YES];
    }
    
    for (UIView *view in self.disabledUIElements) {
        view.userInteractionEnabled = YES;
        view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    }
}

- (void)hideProgressHUD
{
    [_progressHUD hide:YES];
    
    for (UIView *view in self.disabledUIElements) {
        view.userInteractionEnabled = YES;
        view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    }
}

- (void)showProgressHUDSpinner
{
    [self showProgressHUDSpinnerWithText:nil];
}

- (void)showProgressHUDSpinnerWithText:(NSString *)text
{
    for (UIView *view in self.disabledUIElements) {
        view.userInteractionEnabled = NO;
        view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    }
    
    _progressHUD.mode = MBProgressHUDModeIndeterminate;
    _progressHUD.labelText = text;
    [_progressHUD show:YES];
}

@end
