//
//  FAGlobalEventHandler.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAGlobalEventHandler.h"
#import "FATrakt.h"
#import "FATraktCache.h"

#import "FAAuthViewController.h"

#import "FAViewControllerPreferredContentSizeChanged.h"
#import "FAAuthWindow.h"

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

@property UIWindow *loginWindow;

@end

@implementation FAGlobalEventHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
        self.networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again. Trakt may also be over capacity.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        self.serviceUnavailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Over capacity", nil) message:NSLocalizedString(@"Trakt is currently over capacity. Try again in a few seconds.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        self.needsLoginAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not logged in", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Log In", nil), nil];
        
        self.lastNetworkErrorDate = [NSDate distantFuture];
        
        // Dynamic Type Setting
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    return self;
}

+ (instancetype)handler
{
    static dispatch_once_t once;
    static FAGlobalEventHandler *handler;
    dispatch_once(&once, ^ {
        handler = [[FAGlobalEventHandler alloc] init];
    });
    return handler;
}

- (void)setUpLogging
{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"logging"];
    
    FALogFormatter *logFormatter = [[FALogFormatter alloc] init];
    
    DDASLLogger *aslLogger = [DDASLLogger sharedInstance];
    [aslLogger setLogFormatter:logFormatter];
    [DDLog addLogger:aslLogger];
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setLogFormatter:logFormatter];
    [DDLog addLogger:ttyLogger];
}

- (void)handleApplicationLaunch
{
    [self setUpLogging];
    
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        if (!valid) {
            [[FAGlobalEventHandler handler] handleInvalidCredentials];
        }
    }];
    
    // Let a thread load the cache from disk to improve launch time for a few fractions of a second ;)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        [[FATraktCache sharedInstance] reloadFromDisk];
    });
    
    /*
    [self performBlock:^{
        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        FACheckinViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"checkin"];
        FATraktCheckin *checkin = [[FATraktCheckin alloc] initWithJSONDict:[@"{\
                                                                            \"status\": \"success\",\
                                                                            \"message\": \"checked in to Batman Begins (2005)\",\
                                                                            \"timestamps\": {\
                                                                            \"start\": 1380680820,\
                                                                            \"end\": 1380681000,\
                                                                            \"active_for\": 8460\
                                                                            },\
                                                                            \"movie\": {\
                                                                            \"title\": \"Batman Begins\",\
                                                                            \"year\": 2005,\
                                                                            \"imdb_id\": \"tt0372784\",\
                                                                            \"tmdb_id\": 808\
                                                                            },\
                                                                            \"show\": {\
                                                                            \"title\": \"The Walking Dead\",\
                                                                            \"year\": 2010,\
                                                                            \"imdb_id\": \"tt1520211\",\
                                                                            \"tvdb_id\": 153021\
                                                                            },\
                                                                            \"facebook\": true,\
                                                                            \"twitter\": false,\
                                                                            \"tumblr\": false,\
                                                                            \"path\": false\
                                                                            }" objectFromJSONString]];
        
        [viewController loadCheckin:checkin];
        
        
        [[UIViewController topViewController] presentViewControllerInsideNavigationController:viewController animated:YES completion:nil];
    } afterDelay:0.1];*/
}

- (void)handleApplicationResume
{
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
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
    } else if (response.responseType == FATraktConnectionResponseTypeServiceUnavailable) {
        [self showNetworkAlertViewIfNeeded:_serviceUnavailableAlert];
    } else if (response.responseType == FATraktConnectionResponseTypeNetworkUnavailable) {
        [self showNetworkAlertViewIfNeeded:_networkNotAvailableAlert];
    } else if (response.responseType == FATraktConnectionResponseTypeInvalidCredentials) {
        [self handleInvalidCredentials];
    }
}

- (void)showNetworkAlertViewIfNeeded:(UIAlertView *)alertView
{
    @synchronized(self) {
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:_lastNetworkErrorDate] > 30) {
            if (!alertView.visible && !_timeoutAlert.visible && !_networkNotAvailableAlert.visible && !_serviceUnavailableAlert.visible) {
                // It has been 30 seconds after the last alert has been dismissed and none is being shown right now
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
        [(UIViewController <FAViewControllerPreferredContentSizeChanged> *)topViewController preferredContentSizeChanged];
    }
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
