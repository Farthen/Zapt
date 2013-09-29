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
#import "FATraktCache.h"
#import "FALogFormatter.h"

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
    UIAlertView *_invalidCredentialsAlert;
    BOOL _authViewShowing;
    UIWindow *_authWindow;
}

@end

@implementation FAAppDelegate

@synthesize authViewShowing = _authViewShowing;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // TestFlight SDK
    [TestFlight takeOff:@"3ac925de-67dd-43f0-9e1a-602e269ab57b"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"logging"];
    
    _timeoutAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Timeout", nil) message:NSLocalizedString(@"Timeout connecting to Trakt. Check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    _networkNotAvailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Problem", nil) message:NSLocalizedString(@"Network not available. Check your internet connection and try again. Trakt may also be over capacity.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    _invalidCredentialsAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Login", nil) message:NSLocalizedString(@"Invalid Trakt username and/or password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Change", nil) otherButtonTitles: nil];
    _serviceUnavailableAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Over capacity", nil) message:NSLocalizedString(@"Trakt is currently over capacity. Try again in a few seconds.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
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
    
    self.window.tintColor = [UIColor purpleColor];
    
    DDLogInfo(@"%@ Version %@", name, version);
    return YES;
}

- (void)handleConnectionErrorResponse:(FATraktConnectionResponse *)response
{
    if (response.responseType == FATraktConnectionResponseTypeTimeout) {
    } else if (response.responseType == FATraktConnectionResponseTypeServiceUnavailable) {
        [_serviceUnavailableAlert show];
    } else if (response.responseType == FATraktConnectionResponseTypeNetworkUnavailable) {
        [_networkNotAvailableAlert show];
    } else if (response.responseType == FATraktConnectionResponseTypeInvalidCredentials) {
        [self handleInvalidCredentials];
    }
}

- (void)handleTimeout
{
    [_timeoutAlert show];
}

- (void)handleInvalidCredentials
{
    [self performLoginAnimated:YES];
    if ([[FATraktConnection sharedInstance] usernameAndPasswordSaved]) {
        [_invalidCredentialsAlert show];
    }
}

- (void)performLoginAnimated:(BOOL)animated
{
    if (!_authViewShowing) {
        _authViewShowing = YES;
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"auth"];
        DDLogViewController(@"Presenting View Controller %@", authController);
        //_authWindow.rootViewController = authController;
        authController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[_authWindow makeKeyAndVisible];
        UINavigationController *navigationController = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        [navigationController.visibleViewController presentViewController:authController animated:animated completion:^{
            _authViewShowing = NO;
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
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
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

@end
