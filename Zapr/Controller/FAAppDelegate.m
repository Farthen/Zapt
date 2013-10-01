//
//  FAAppDelegate.m
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAAppDelegate.h"
#import "FATrakt.h"
#import "FAConnectingViewController.h"
#import "FAAuthViewController.h"
#import "FATraktCache.h"
#import "FALogFormatter.h"
#import "RNTimer.h"

#import "UIViewController+PresentInsideNavigationController.h"

#import "TestFlight.h"

#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>

#import "FADominantColorsAnalyzer.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_INFO

@interface FAAppDelegate () {
    UIAlertView *_timeoutAlert;
    UIAlertView *_networkNotAvailableAlert;
    UIAlertView *_serviceUnavailableAlert;
    UIAlertView *_needsLoginAlertView;
    BOOL _authViewShowing;
    UIWindow *_authWindow;
    
    RNTimer *_loginTimer;
    
    NSDate *_lastNetworkErrorDate;
}

@property NSDate *compilationDate;

@end

@implementation FAAppDelegate

@synthesize authViewShowing = _authViewShowing;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // TestFlight SDK
#ifndef DEBUG
    [TestFlight takeOff:@"3ac925de-67dd-43f0-9e1a-602e269ab57b"];
#endif
        
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"logging"];
    
    _timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again. Trakt may also be over capacity.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    _serviceUnavailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Over capacity", nil) message:NSLocalizedString(@"Trakt is currently over capacity. Try again in a few seconds.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    _needsLoginAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not logged in", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Log In", nil), nil];
    
    _lastNetworkErrorDate = [NSDate distantPast];
    
    _authViewShowing = NO;
    
    FALogFormatter *logFormatter = [[FALogFormatter alloc] init];
    
    DDASLLogger *aslLogger = [DDASLLogger sharedInstance];
    [aslLogger setLogFormatter:logFormatter];
    [DDLog addLogger:aslLogger];
    
    DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
    [ttyLogger setLogFormatter:logFormatter];
    [DDLog addLogger:ttyLogger];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDict objectForKey:@"CFBundleVersion"];
    
    _authViewShowing = NO;
    
    _authWindow = [[UIWindow alloc] init];
    
    // Let a thread load the cache from disk to improve launch time for a few fractions of a second ;)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        [FATraktCache sharedInstance];
    });
    
    // Dynamic Type Setting
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.tintColor = [UIColor purpleColor];
    self.window.tintColor = self.tintColor;
    
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        if (!valid) {
            [self handleInvalidCredentials];
        }
    }];
    
    DDLogInfo(@"%@ Version %@", name, version);
    return YES;
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

- (void)performLoginAnimated:(BOOL)animated showInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt
{
    if (!_authViewShowing) {
        _authViewShowing = YES;
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        FAAuthViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"auth"];
        DDLogViewController(@"Presenting View Controller %@", authController);        
        authController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        authController.showsInvalidPrompt = showInvalidCredentialsPrompt;

        [self.window makeKeyAndVisible];
        UIViewController *topViewcontroller = [self topViewController];
        
        _loginTimer = [RNTimer repeatingTimerWithTimeInterval:0.05 block:^{
            if (topViewcontroller.isViewLoaded &&
                topViewcontroller.view.window &&
                topViewcontroller.view.superview) {
                [_loginTimer invalidate];
                _loginTimer = nil;
                [topViewcontroller presentViewControllerInsideNavigationController:authController animated:animated completion:^{
                    _authViewShowing = NO;
                }];
            }
        }];
    }
}

- (void)preferredContentSizeChanged:(NSNotification *)notification
{
    // Check if the top viewController supports layout
    UIViewController *topViewController = [self topViewController];
    if (topViewController && [topViewController conformsToProtocol:@protocol(FAViewControllerPreferredContentSizeChanged)]) {
        [(UIViewController <FAViewControllerPreferredContentSizeChanged> *)topViewController preferredContentSizeChanged];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FATraktCache sharedInstance] saveToDisk];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[FATraktCache sharedInstance] reloadFromDisk];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FATraktCache sharedInstance] saveToDisk];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[self.window rootViewController]];
}

// http://stackoverflow.com/a/17578272/1084385
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _needsLoginAlertView) {
        if (buttonIndex == 1) {
            [self performLoginAnimated:YES showInvalidCredentialsPrompt:NO];
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

@end
