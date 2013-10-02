//
//  FAGlobalSettings.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAGlobalSettings.h"

@implementation FAGlobalSettings

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static FAGlobalSettings *instance;
    dispatch_once(&once, ^ {
        instance = [[FAGlobalSettings alloc] init];
    });
    return instance;
}

- (UIColor *)tintColor
{
    return [UIColor purpleColor];
}

@end
