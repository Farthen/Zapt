//
//  FAGlobalSettings.m
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAGlobalSettings.h"

@interface FAGlobalSettings ()
@end

@implementation FAGlobalSettings
@synthesize userDefaults = _userDefaults;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static FAGlobalSettings *instance;
    dispatch_once(&once, ^{
        instance = [[FAGlobalSettings alloc] init];
    });
    
    return instance;
}

- (UIColor *)tintColor
{
    return [UIColor purpleColor];
}

- (void)setHideCompletedShows:(BOOL)hideCompletedShows
{
    [self.userDefaults setBool:hideCompletedShows forKey:@"hideCompletedShows"];
}

- (BOOL)hideCompletedShows
{
    return [self.userDefaults boolForKey:@"hideCompletedShows"];
}

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.de.farthen.Zapt"];
    }
    
    return _userDefaults;
}

@end
