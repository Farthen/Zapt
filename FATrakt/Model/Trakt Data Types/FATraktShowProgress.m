//
//  FATraktShowProgress.m
//  Zapt
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktShowProgress.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

@interface FATraktShowProgress ()
@property (nonatomic) NSString *showCacheKey;
@property (nonatomic) NSString *nextEpisodeCacheKey;
@end

@implementation FATraktShowProgress

- (instancetype)initWithJSONDict:(NSDictionary *)dict
{
    FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:dict[@"show"]];
    _showCacheKey = show.cacheKey;
    
    return [super initWithJSONDict:dict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktShowProgress %p for show \"%@\">", self, self.show];
}

- (void)finishedMappingObjects
{
    if (self.next_episode) {
        self.next_episode.show = self.show;
    }
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"progress"]) {
        // This is the progress dict. Parse it and put it directly in here
        NSDictionary *progressDict = (NSDictionary *)object;
        
        for (NSString *key in progressDict) {
            if ([key isEqualToString:@"percentage"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"percentage"];
            } else if ([key isEqualToString:@"aired"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"aired"];
            } else if ([key isEqualToString:@"completed"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"completed"];
            } else if ([key isEqualToString:@"left"]) {
                [self mapObject:progressDict[key] toPropertyWithKey:@"left"];
            }
        }
    } else if ([key isEqualToString:@"show"]) {
        FATraktShow *show = [[FATraktShow alloc] initWithJSONDict:object];
        
        self.show = [show cachedVersion];
        show.progress = self;
        [self.show commitToCache];
        
    } else if ([key isEqualToString:@"next_episode"]) {
        FATraktEpisode *next_episode = [[FATraktEpisode alloc] initWithJSONDict:object andShow:self.show];
        
        [next_episode commitToCache];
        self.next_episode = next_episode;
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObjects:@"show", @"next_episode", nil];
}

- (void)setShow:(FATraktShow *)show
{
    self.showCacheKey = show.cacheKey;
}

- (FATraktShow *)show
{
    return [[FATraktShow backingCache] objectForKey:self.showCacheKey];
}

- (void)setNext_episode:(FATraktEpisode *)next_episode
{
    self.nextEpisodeCacheKey = next_episode.cacheKey;
}

- (FATraktEpisode *)next_episode
{
    return [[FATraktEpisode backingCache] objectForKey:self.nextEpisodeCacheKey];
}

@end
