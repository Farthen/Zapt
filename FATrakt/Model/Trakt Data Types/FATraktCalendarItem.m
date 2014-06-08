//
//  FATraktCalendarItem.m
//  Zapt
//
//  Created by Finn Wilke on 18/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktCalendarItem.h"
#import "FATraktCache.h"
#import "FATraktEpisode.h"

static NSDateFormatter *traktCalendarItemDateFormatter = nil;

@interface FATraktCalendarItem ()
@property (nonatomic) NSArray *episodeCacheKeys;
@end

@implementation FATraktCalendarItem

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"date"]) {
        if (!traktCalendarItemDateFormatter) {
            traktCalendarItemDateFormatter = [[NSDateFormatter alloc] init];
            traktCalendarItemDateFormatter.dateFormat = @"yyyy-MM-dd";
        }
        
        self.date = [traktCalendarItemDateFormatter dateFromString:object];
    } else if ([key isEqualToString:@"episodes"]) {
        
        self.episodes = [object mapUsingBlock:^id(NSDictionary *episodeDict, NSUInteger idx) {
            return [[FATraktEpisode alloc] initWithJSONDict:episodeDict];
        }];
        
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (void)setEpisodes:(NSArray *)episodes
{
    self.episodeCacheKeys = [episodes mapUsingBlock:^id(id obj, NSUInteger idx) {
        return [obj cacheKey];
    }];
}

- (NSArray *)episodes
{
    return [self.episodeCacheKeys mapUsingBlock:^id(id cacheKey, NSUInteger idx) {
        return [FATraktEpisode objectWithCacheKey:cacheKey];
    }];
}

@end
