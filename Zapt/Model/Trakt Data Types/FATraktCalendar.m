//
//  FATraktCalendar.m
//  Zapt
//
//  Created by Finn Wilke on 18/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktCalendar.h"
#import "FATraktCache.h"
#import "FATraktCalendarItem.h"

@implementation FATraktCalendar

- (instancetype)initWithJSONArray:(NSArray *)array
{
    self = [super init];
    
    if (self) {
        [self mapObject:array toPropertyWithKey:NSStringFromSelector(@selector(calendarItems))];
    }
    
    return self;
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"calendarItems"]) {
        
        NSArray *calendarItemDicts = object;
        self.calendarItems = [calendarItemDicts mapUsingBlock:^id(id obj, NSUInteger idx) {
            return [[FATraktCalendarItem alloc] initWithJSONDict:obj];
        }];
        
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

+ (instancetype)cachedCalendar
{
    return [FATraktCalendar objectWithCacheKey:self.cacheKey];
}

+ (NSString *)cacheKey
{
    return @"<FATraktCalendar>";
}

- (NSString *)cacheKey
{
    return [self.class cacheKey];
}

+ (TMCache *)backingCache
{
    return [FATraktCache sharedInstance].calendar;
}

- (id)newValueForMergingKey:(NSString *)key fromOldObject:(id)oldObject propertyInfo:(FAPropertyInfo *)propertyInfo
{
    return [self valueForKey:key];
}

@end
