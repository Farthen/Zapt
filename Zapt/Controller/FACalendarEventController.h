//
//  FACalendarEventController.h
//  Zapt
//
//  Created by Finn Wilke on 25/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#import "FATrakt.h"

@interface FACalendarEventController : NSObject

+ (instancetype)sharedInstance;
- (void)addCalendarEventForContent:(FATraktEpisode *)episode;

@end
