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
    UIAlertView *_invalidCredentialsAlert;
}

@end

@implementation FAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@"Application Launched");
    _timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _invalidCredentialsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Login", nil) message:NSLocalizedString(@"Invalid Trakt username and/or password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Retry", nil) otherButtonTitles: nil];
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

- (void)handleInvalidCredentials
{
    [_invalidCredentialsAlert show];
}

- (void)performInitialLogin:(id)sender
{
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    FAConnectingViewController *connectingController = [storyboard instantiateViewControllerWithIdentifier:@"connect"];
    [sender presentViewController:connectingController animated:NO completion:nil];
    [self performLoginIfRequired:connectingController animated:NO];
}

- (void)performLoginIfRequired:(id)sender animated:(BOOL)animated
{
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        if (!valid) {
            UIViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"auth"];
            NSLog(@"Presenting View Controller %@", authController);
            [sender presentViewController:authController animated:animated completion:nil];
        } else {
            [sender dismissViewControllerAnimated:NO completion:nil];
        }
    }];
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
