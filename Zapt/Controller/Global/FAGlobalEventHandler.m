//
//  FAGlobalEventHandler.m
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"

#import "FAGlobalEventHandler.h"
#import "FAGlobalSettings.h"
#import "FAZapt.h"

#import "FAAuthViewController.h"
#import "FACheckinViewController.h"

#import "FAViewControllerPreferredContentSizeChanged.h"
#import "FAAuthWindow.h"

#import "FAConnectionDelegate.h"

#import "FALogFormatter.h"
#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>

@interface FAGlobalEventHandler ()
@property UIAlertView *serviceUnavailableAlert;
@property UIAlertView *networkNotAvailableAlert;
@property UIAlertView *timeoutAlert;
@property UIAlertView *needsLoginAlertView;
@property NSDate *lastNetworkErrorDate;

@property (nonatomic) FAConnectionDelegate *connectionDelegate;

@property UIWindow *loginWindow;

@end

@implementation FAGlobalEventHandler

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        self.networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again. Trakt may also be over capacity.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        self.serviceUnavailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Over capacity", nil) message:NSLocalizedString(@"Trakt is currently over capacity. Try again in a few minutes.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
        self.needsLoginAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You need to be logged in for this action.", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Log In", nil), nil];
        
        self.lastNetworkErrorDate = [NSDate distantPast];
        
        // Dynamic Type Setting
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

+ (instancetype)handler
{
    static dispatch_once_t once;
    static FAGlobalEventHandler *handler;
    dispatch_once(&once, ^{
        handler = [[FAGlobalEventHandler alloc] init];
    });
    
    return handler;
}

- (void)setUpLogging
{
    [[FAGlobalSettings sharedInstance].userDefaults setInteger:1 forKey:@"logging"];
    
    FALogFormatter *logFormatter = [[FALogFormatter alloc] init];
    
    DDASLLogger *aslLogger = [DDASLLogger sharedInstance];
    [aslLogger setLogFormatter:logFormatter];
    [DDLog addLogger:aslLogger withLogLevel:LOG_LEVEL_ALL];
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setLogFormatter:logFormatter];
    [DDLog addLogger:ttyLogger withLogLevel:LOG_LEVEL_ALL];
}

- (void)doMigrationIfNeccessary
{
    // Remove old FACache if neccessary
    if (![[FAGlobalSettings sharedInstance].userDefaults boolForKey:@"migrationRemovedFACache"]) {
        [[FATraktCache sharedInstance] migrationRemoveFACache];
    }
}

- (void)handleApplicationLaunch
{
    [self doMigrationIfNeccessary];
    
    [self setUpLogging];
    
    [FATrakt sharedInstance].versionNumberString = [FAZapt versionNumberString];
    [FATrakt sharedInstance].buildString = [FAZapt buildString];
    
    self.connectionDelegate = [[FAConnectionDelegate alloc] initWithConnection:[FATraktConnection sharedInstance]];
    
    if ([FATraktConnection sharedInstance].usernameAndPasswordSaved) {
        [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid) {
            if (!valid) {
                [[FAGlobalEventHandler handler] handleInvalidCredentials];
            }
        }];
    }
}

- (void)handleApplicationResume
{
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid) {
        if (!valid) {
            [[FAGlobalEventHandler handler] handleInvalidCredentials];
        }
    }];
}

- (void)performLoginAnimated:(BOOL)animated showInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt completion:(void (^)(void))completion
{
    [[FAAuthWindow window] showIfNeededAnimated:animated withInvalidCredentialsPrompt:showInvalidCredentialsPrompt completion:completion];
}

- (void)performLoginAnimated:(BOOL)animated showInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt
{
    [self performLoginAnimated:animated showInvalidCredentialsPrompt:showInvalidCredentialsPrompt completion:nil];
}

- (void)handleConnectionErrorResponse:(FATraktConnectionResponse *)response
{
    if (response.responseType == FATraktConnectionResponseTypeTimeout) {
        [self showNetworkAlertViewIfNeeded:_networkNotAvailableAlert];
    } else if (response.responseType == FATraktConnectionResponseTypeServiceUnavailable) {
        [self showNetworkAlertViewIfNeeded:_serviceUnavailableAlert];
    } else if (response.responseType == FATraktConnectionResponseTypeNetworkUnavailable) {
        [self showNetworkAlertViewIfNeeded:_networkNotAvailableAlert];
    } else if (response.responseType == FATraktConnectionResponseTypeInvalidCredentials) {
        [self handleInvalidCredentials];
    } else if (response.responseType != FATraktConnectionResponseTypeNotFound) {
        [self showNetworkAlertViewIfNeeded:_serviceUnavailableAlert];
    }
}

- (void)showNetworkAlertViewIfNeeded:(UIAlertView *)alertView
{
    @synchronized(self)
    {
        NSDate *now = [NSDate date];
        
        if ([now timeIntervalSinceDate:_lastNetworkErrorDate] > 5) {
            if (!alertView.visible && !_timeoutAlert.visible && !_networkNotAvailableAlert.visible && !_serviceUnavailableAlert.visible) {
                // It has been 5 seconds after the last alert has been dismissed and none is being shown right now
                // This is just because nobody wants bazillion alert boxes stacked on top of each other
                [alertView show];
            }
        }
    }
}

- (void)handleTimeout
{
    [self showNetworkAlertViewIfNeeded:_timeoutAlert];
}

- (void)showNeedsLoginAlertWithActionName:(NSString *)actionName
{
    if (!actionName) {
        actionName = NSLocalizedString(@"use this feature", nil);
    }
    
    _needsLoginAlertView.message = [NSString stringWithFormat:NSLocalizedString(@"To %@ you need to log in to your Trakt account", nil), actionName];
    [_needsLoginAlertView show];
}

- (void)handleInvalidCredentials
{
    [self performLoginAnimated:YES showInvalidCredentialsPrompt:YES];
}

- (void)performLoginAnimated:(BOOL)animated
{
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Check if the top viewController supports layout
    UIViewController *topViewController = [UIViewController topViewController];
    
    if (topViewController && [topViewController conformsToProtocol:@protocol(FAViewControllerPreferredContentSizeChanged)]) {
        [(UIViewController < FAViewControllerPreferredContentSizeChanged > *) topViewController preferredContentSizeChanged];
    }
}

- (void)performRegisterAccount
{
    NSURL *joinURL = [NSURL URLWithString:@"http://trakt.tv/join"];
    [[UIApplication sharedApplication] openURL:joinURL];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _needsLoginAlertView) {
        if (buttonIndex == 1) {
            [[FAGlobalEventHandler handler] performLoginAnimated:YES showInvalidCredentialsPrompt:NO];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _timeoutAlert ||
        alertView == _networkNotAvailableAlert ||
        alertView == _serviceUnavailableAlert) {
        // update the last dismissed date
        _lastNetworkErrorDate = [NSDate date];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
