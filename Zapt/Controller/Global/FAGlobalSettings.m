//
//  FAGlobalSettings.m
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAGlobalSettings.h"

@interface FAGlobalSettings ()
@property NSUserDefaults *userDefaults;
@end

@implementation FAGlobalSettings

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
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

@end
