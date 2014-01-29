//
//  FAAppDelegate.m
//  Zapt
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAAppDelegate.h"

#ifndef RELEASE
#import "TestFlight.h"
#endif

#import "FAGlobalEventHandler.h"
#import "FAGlobalSettings.h"
#import "FAZapt.h"

#import "FATraktCache.h"

@interface FAAppDelegate ()
@end

@implementation FAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // TestFlight SDK
#ifndef DEBUG
#ifndef RELEASE
    [TestFlight takeOff:@"bd1a97eb-c0bd-4e93-aaac-166911b86304"];
#endif
#endif
    
    self.window.tintColor = [FAGlobalSettings sharedInstance].tintColor;
    
    [[FAGlobalEventHandler handler] handleApplicationLaunch];
    
    DDLogInfo(@"%@ Version %@", [FAZapt applicationName], [FAZapt versionNumberDescription]);
    
    
    
    return YES;
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
    
    [[FAGlobalEventHandler handler] handleApplicationResume];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[FAZapt versionNumberString] forKey:@"FAZaptVersionNumber"];
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    //return NO;
    NSString *versionNumber = [coder decodeObjectForKey:@"FAZaptVersionNumber"];
    return [versionNumber isEqualToString:[FAZapt versionNumberString]];
}

@end
