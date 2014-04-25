//
//  FACalendarEventController.m
//  Zapt
//
//  Created by Finn Wilke on 25/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FACalendarEventController.h"

@implementation FACalendarEventController

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    
    return instance;
}

- (void)addCalendarEventForContent:(FATraktEpisode *)episode
{
    
}

@end
