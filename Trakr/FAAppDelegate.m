//
//  FAAppDelegate.m
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAAppDelegate.h"
#import "FATrakt.h"
#import "FAConnectingViewController.h"

@interface FAAppDelegate () {
    UIAlertView *_timeoutAlert;
    UIAlertView *_networkNotAvailableAlert;
    UIAlertView *_overCapacityAlert;
    UIAlertView *_invalidCredentialsAlert;
    BOOL _authViewShowing;
}

@end

@implementation FAAppDelegate

@synthesize authViewShowing = _authViewShowing;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [APLog tiny:@"Application Launched"];
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"logging"];
    
    _timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _invalidCredentialsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Login", nil) message:NSLocalizedString(@"Invalid Trakt username and/or password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Retry", nil) otherButtonTitles: nil];
    _overCapacityAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Over capacity", nil) message:NSLocalizedString(@"Trakt is currently over capacity. Try again in a few seconds.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _authViewShowing = NO;
    return YES;
}

- (void)handleTimeout
{
    [_timeoutAlert show];
}

- (void)handleNetworkNotAvailable
{
    [_networkNotAvailableAlert show];
}

- (void)handleOverCapacity
{
    
}

- (void)handleInvalidCredentials
{
    if (![[FATrakt sharedInstance] usernameAndPasswordSaved]) {
        [self performLoginAnimated:YES];
    } else {
        [self performLoginAnimated:YES];
        [_invalidCredentialsAlert show];
    }
}

- (void)performLoginAnimated:(BOOL)animated
{
    if (!_authViewShowing) {
        _authViewShowing = YES;
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"auth"];
        [APLog tiny:@"Presenting View Controller %@", authController];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:authController animated:animated completion:nil];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
