//
//  FAActivityDispatch.m
//  Zapr
//
//  Created by Finn Wilke on 18.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAActivityDispatch.h"
#import "FAUIElementWithActivity.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_ERROR

static NSString *FAActivityDispatchNotificationAll = @"FAActivityDispatchNotificationAll";

@implementation FAActivityDispatch

+ (FAActivityDispatch *)sharedInstance
{
    static dispatch_once_t once;
    static FAActivityDispatch *instance;
    dispatch_once(&once, ^{ instance = [[FAActivityDispatch alloc] init]; });
    
    return instance;
}

- (NSString *)notificationNameForStartActivity:(NSString *)notificationName
{
    return [notificationName stringByAppendingString:@"DidStart"];
}

- (NSString *)notificationNameForFinishActivity:(NSString *)notificationName
{
    return [notificationName stringByAppendingString:@"DidFinish"];
}

- (NSString *)stopAllNotificationNameForName:(NSString *)notificationName
{
    return [notificationName stringByAppendingString:@"StopAll"];
}

- (void)registerForAllActivity:(id <FAUIElementWithActivity> )observer
{
    [self registerForActivityName:FAActivityDispatchNotificationAll observer:observer];
}

- (void)registerForActivityName:(NSString *)name observer:(id <FAUIElementWithActivity> )observer
{
    NSString *didStartName = [self notificationNameForStartActivity:name];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(startActivity) name:didStartName object:nil];
    
    NSString *didFinishName = [self notificationNameForFinishActivity:name];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(finishActivity) name:didFinishName object:nil];
    
    NSString *stopAllName = [self stopAllNotificationNameForName:name];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(stopAllActivity) name:stopAllName object:nil];
    
    DDLogController(@"Registered observer: %@ for: %@, %@, %@", observer, didStartName, didFinishName, stopAllName);
}

- (void)unregister:(id <FAUIElementWithActivity> )observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    
    if ([observer respondsToSelector:@selector(stopAllActivity)]) {
        [observer stopAllActivity];
    }
}

- (void)startActivityNamed:(NSString *)name
{
    if (name) {
        DDLogController(@"Starting activity named: %@", name);
        NSString *startName = [self notificationNameForStartActivity:name];
        [[NSNotificationCenter defaultCenter] postNotificationName:startName object:self];
        
        NSString *startNameAll = [self notificationNameForStartActivity:FAActivityDispatchNotificationAll];
        [[NSNotificationCenter defaultCenter] postNotificationName:startNameAll object:self];
    }
}

- (void)startActivityNamed:(NSString *)name count:(NSUInteger)count
{
    while (count > 0) {
        [self startActivityNamed:name];
        count--;
    }
}

- (void)finishActivityNamed:(NSString *)name
{
    DDLogController(@"Stopping activity named: %@", name);
    
    if (name) {
        NSString *finishName = [self notificationNameForFinishActivity:name];
        [[NSNotificationCenter defaultCenter] postNotificationName:finishName object:self];
        
        NSString *finishNameAll = [self notificationNameForFinishActivity:FAActivityDispatchNotificationAll];
        [[NSNotificationCenter defaultCenter] postNotificationName:finishNameAll object:self];
    }
}

- (void)stopAllNamed:(NSString *)name
{
    if (name) {
        NSString *stopAllName = [self stopAllNotificationNameForName:name];
        [[NSNotificationCenter defaultCenter] postNotificationName:stopAllName object:self];
        
        NSString *stopAllNameAll = [self stopAllNotificationNameForName:FAActivityDispatchNotificationAll];
        [[NSNotificationCenter defaultCenter] postNotificationName:stopAllNameAll object:self];
    }
}

@end
