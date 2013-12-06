//
//  FATraktSeason.m
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSeason.h"
#import "FATraktEpisode.h"
#import "FATraktShow.h"

#import "FATraktCache.h"

@implementation FATraktSeason {
    __weak FATraktShow *_show;
    NSString *_showCacheKey;
    NSMutableArray *_episodes;
    NSArray *_episodeCacheKeys;
    NSNumber *_episodeCount;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktSeason %p season %@ of show with title: %@>", self, self.seasonNumber, self.show.title];
}

- (void)finishedMappingObjects
{
    [super finishedMappingObjects];
    
    for (FATraktEpisode *episode in self.episodes) {
        episode.seasonNumber = self.seasonNumber;
        episode.showCacheKey = self.showCacheKey;
    }
}

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    _show = show;
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.show = show;
    }
    return self;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"episodes"]) {
        if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *episodesArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
            for (id item in (NSArray *)object) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *episodeDict = item;
                    FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:_show];
                    [episodesArray addObject:episode];
                } else if ([item isKindOfClass:[NSNumber class]]) {
                    FATraktEpisode *episode = [[FATraktEpisode alloc] init];
                    
                    // the rest will be filled in finishedMappingObjects
                    episode.episodeNumber = item;
                    episode.detailLevel = FATraktDetailLevelMinimal;
                    
                    [episodesArray addObject:episode];
                }
            }
            
            [self setValue:[NSArray arrayWithArray:episodesArray] forKey:key];
        } else if ([object isKindOfClass:[NSNumber class]]) {
            // Only basic season information
            self.episodeCount = object;
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"season"]) {
        [self mapObject:object toPropertyWithKey:@"seasonNumber"];
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObjects:@"show", @"episodes", nil];
}

- (FATraktEpisode *)episodeWithID:(NSUInteger)episodeID
{
    if (self.episodes) {
        for (FATraktEpisode *episode in self.episodes) {
            if (episode.episodeNumber.unsignedIntegerValue == episodeID) {
                return episode;
            }
        }
    } else if (self.episodeCount) {
        if (self.episodeCount.unsignedIntegerValue >= episodeID) {
            FATraktEpisode *episode = [[FATraktEpisode alloc] init];
            episode.show = self.show;
            episode.seasonNumber = self.seasonNumber;
            episode.episodeNumber = [NSNumber numberWithUnsignedInteger:episodeID];
            episode.detailLevel = FATraktDetailLevelMinimal;
            return episode;
        }
    }
    
    return nil;
}

- (NSString *)cacheKey
{
    NSString *showKey;
    if (!self.show) {
        // If the show is unavailable for some reason, generate a UUID to avoid collisions
        showKey = [NSString uuidString];
    } else {
        showKey = self.show.cacheKey;
    }
    
    return [NSString stringWithFormat:@"FATraktSeason&%@&season=%@", showKey, self.seasonNumber.stringValue];
}

+ (FACache *)backingCache
{
    return FATraktCache.sharedInstance.content;
}

- (void)setEpisodeCount:(NSNumber *)episodeCount
{
    _episodeCount = episodeCount;
}

- (NSNumber *)episodeCount
{
    if (self.episodes) {
        return [NSNumber numberWithUnsignedInteger:self.episodes.count];
    }
    
    return _episodeCount;
}

- (NSNumber *)episodesWatched
{
    return [NSNumber numberWithUnsignedInteger:[self.episodes countUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ((FATraktEpisode *)obj).watched == YES;
    }]];
}

- (void)setShow:(FATraktShow *)show
{
    _show = show;
    
    // This prevents a retain loop:
    // Show will retain season but season will not retain show
    // To keep show in memory we need to put season in the array though
    if (show) {
        if (!show.seasons) {
            show.seasons = [NSMutableArray array];
        }
        
        while (show.seasons.count < self.seasonNumber.unsignedIntegerValue) {
            FATraktSeason *season = [[FATraktSeason alloc] init];
            season->_show = show;
            season.seasonNumber = [NSNumber numberWithUnsignedInteger:show.seasons.count - 1 + 1];
            [show.seasons addObject:[NSMutableArray array]];
        }
        
        if (show.seasons.count == self.seasonNumber.unsignedIntegerValue - 1) {
            [show.seasons addObject:self];
        } else {
            show.seasons[self.seasonNumber.unsignedIntegerValue] = self;
        }
        
        [show commitToCache];
    }
}

- (FATraktShow *)show
{
    if (!_show) {
        if (_showCacheKey) {
            _show = [FATraktShow.backingCache objectForKey:_showCacheKey];
        }
    }
    
    return _show;
}

- (void)setShowCacheKey:(NSString *)showCacheKey
{
    _showCacheKey = showCacheKey;
}

- (NSString *)showCacheKey
{
    if (_show) {
        return _show.cacheKey;
    }
    
    return _showCacheKey;
}

- (void)setEpisodes:(NSMutableArray *)episodes
{
    _episodes = episodes;
}

- (NSMutableArray *)episodes
{
    if (!_episodes) {
        _episodes = [_episodeCacheKeys mapUsingBlock:^id(id obj, NSUInteger idx) {
            FATraktEpisode *episode = [FATraktEpisode.backingCache objectForKey:obj];
            
            if (!episode) {
                episode = [[FATraktEpisode alloc] init];
                episode.episodeNumber = [NSNumber numberWithUnsignedInteger:idx + 1];
                episode.seasonNumber = self.seasonNumber;
            }
            
            return episode;
        }];
        
        for (FATraktEpisode *episode in [_episodes copy]) {
            episode.show = self.show;
        }
    }
    
    return _episodes;
}

- (void)setEpisodeCacheKeys:(NSArray *)episodeCacheKeys
{
    _episodeCacheKeys = episodeCacheKeys;
}

- (NSArray *)episodeCacheKeys
{
    if (_episodes) {
        return [_episodes valueForKey:@"cacheKey"];
    }
    
    return _episodeCacheKeys;
}


@end
