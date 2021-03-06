//
//  FATraktSeason.m
//  Zapt
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSeason.h"
#import "FATraktEpisode.h"
#import "FATraktShow.h"

#import "FATraktCache.h"
#import "Misc.h"

@implementation FATraktSeason {
    NSString *_showCacheKey;
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
    
    for (id key in [self.episodesDict copy]) {
        FATraktEpisode *episode = self.episodesDict[key];
        
        episode.seasonNumber = self.seasonNumber;
        episode.showCacheKey = self.showCacheKey;
        episode.season = self;
    }
}

- (instancetype)initWithShow:(FATraktShow *)show seasonNumber:(NSNumber *)seasonNumber
{
    self = [super init];
    
    if (self) {
        self.seasonNumber = seasonNumber;
        self.show = show;
        self.detailLevel = FATraktDetailLevelMinimal;
        
        FATraktSeason *cachedSeason = [self cachedVersion];
        if (cachedSeason) {
            return cachedSeason;
        }
    }
    
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    self.showCacheKey = show.cacheKey;
    
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.show = show;
        self.detailLevel = FATraktDetailLevelDefault;
        
        FATraktSeason *cachedSeason = [self cachedVersion];
        if (cachedSeason) {
            // cache hit!
            // merge the two
            [cachedSeason mergeWithObject:self];
            
            // return the cached show
            self = cachedSeason;
        }
    }
    
    return self;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"episodes"]) {
        if ([object isKindOfClass:[NSArray class]]) {

            for (id item in(NSArray *) object) {
                FATraktEpisode *episode;
                
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *episodeDict = item;
                    episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:self.show];
                    
                } else if ([item isKindOfClass:[NSNumber class]]) {
                    episode = [[FATraktEpisode alloc] init];
                    
                    // the rest will be filled in finishedMappingObjects
                    episode.episodeNumber = item;
                    episode.detailLevel = FATraktDetailLevelMinimal;
                }
                
                [self addEpisode:episode];
            }

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
        self.seasonNumber = object;
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObjects:@"show", @"episodes", nil];
}

- (void)copyVitalDataToNewObject:(id)newDatatype
{
    FATraktSeason *season = newDatatype;
    season.seasonNumber = self.seasonNumber;
    season.show = [self.show copy];
}

- (BOOL)shouldCopyPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"show"] ||
        [key isEqualToString:@"episodes"]) {
        return NO;
    }
    
    return YES;
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
            FATraktEpisode *episode =
            [[FATraktEpisode alloc] initWithShow:self.show
                                    seasonNumber:self.seasonNumber
                                   episodeNumber:[NSNumber numberWithUnsignedInteger:episodeID]];
            
            episode.detailLevel = FATraktDetailLevelMinimal;
            
            return episode;
        }
    }
    
    return nil;
}

- (NSString *)cacheKey
{
    NSString *showKey;
    
    if (!self.showCacheKey) {
        // If the show is unavailable for some reason, generate a UUID to avoid collisions
        showKey = [NSString uuidString];
    } else {
        showKey = self.showCacheKey;
    }
    
    return [NSString stringWithFormat:@"FATraktSeason&show=<%@>&season=%@", showKey, self.seasonNumber.stringValue];
}

+ (TMCache *)backingCache
{
    return FATraktCache.sharedInstance.content;
}

- (void)setEpisodeCount:(NSNumber *)episodeCount
{
    _episodeCount = episodeCount;
}

- (NSNumber *)episodeCount
{
    if (_episodeCount) {
        return _episodeCount;
    }
    
    if (self.episodes) {
        return [NSNumber numberWithUnsignedInteger:self.episodes.count];
    }
    
    return nil;
}

- (NSNumber *)episodesWatched
{
    return [NSNumber numberWithUnsignedInteger:[self.episodes countUsingBlock:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return ((FATraktEpisode *)obj).watched == YES;
    }]];
}

- (void)setShow:(FATraktShow *)show
{
    self.showCacheKey = show.cacheKey;
    
    // This prevents a retain loop:
    // Show will retain season but season will not retain show
    // To keep show in memory we need to put season in the dict though
    if (show) {
        [show addSeason:self];
        [show commitToCache];
    }
}

- (FATraktShow *)show
{
    return [FATraktShow.backingCache objectForKey:_showCacheKey];
}

- (void)setShowCacheKey:(NSString *)showCacheKey
{
    _showCacheKey = showCacheKey;
}

- (NSString *)showCacheKey
{
    return _showCacheKey;
}

- (NSArray *)episodes
{
    if (!self.episodesDict) {
        self.episodesDict = [NSMutableDictionary dictionary];
        
        if (self.episodeCacheKeys) {
            for (NSString *key in self.episodeCacheKeys) {
                FATraktEpisode *episode = [FATraktEpisode.backingCache objectForKey:key];
                
                if (episode && episode.episodeNumber) {
                    episode.show = self.show;
                    episode.season = self;
                    self.episodesDict[episode.episodeNumber] = episode;
                }
            }
        }
    }
    
    return [self.episodesDict.allValues sortedArrayUsingKey:@"episodeNumber" ascending:YES];
}

- (void)setEpisodeCacheKeys:(NSArray *)episodeCacheKeys
{
    _episodeCacheKeys = episodeCacheKeys;
}

- (NSArray *)episodeCacheKeys
{
    if (_episodesDict) {
        return [_episodesDict.allValues valueForKey:@"cacheKey"];
    }
    
    return _episodeCacheKeys;
}

- (void)addEpisode:(FATraktEpisode *)episode
{
    if (!self.episodesDict) {
        self.episodesDict = [NSMutableDictionary dictionary];
    }
    
    if (episode.episodeNumber) {
        FATraktEpisode *oldEpisode = self.episodesDict[episode.episodeNumber];
        
        if (oldEpisode) {
            [episode mergeWithObject:oldEpisode];
        }
        
        self.episodesDict[episode.episodeNumber] = episode;
    }
}

- (FATraktEpisode *)episodeForNumber:(NSNumber *)number
{
    return self.episodesDict[number];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self episodeForNumber:[NSNumber numberWithUnsignedInteger:index]];
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([key isKindOfClass:[NSNumber class]]) {
        return [self episodeForNumber:(NSNumber *)key];
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"- (id)objectForKeyedSubscript: expected an NSNumber as key but got: %@", key];
    
    return nil;
}

- (BOOL)isWatched
{
    return [self.episodes everyUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        FATraktEpisode *episode = obj;
        return episode.watched;
    }];
}

- (NSDictionary *)postDictInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSDictionary *showDictInfo = [self.show postDictInfo];
    
    if (showDictInfo) {
        [dict addEntriesFromDictionary:showDictInfo];
    }
    
    if (self.seasonNumber) {
        [dict setObject:self.seasonNumber forKey:@"season"];
    }
    
    return dict;
}

- (BOOL)shouldMergeObjectForKey:(NSString *)key
{
    if ([key isEqualToString:@"show"]) {
        return NO;
    }
    
    if ([key isEqualToString:@"episodes"]) {
        if (self.episodesDict && self.episodesDict.count != 0) {
            return NO;
        }
    }
    
    return [super shouldMergeObjectForKey:key];
}

@end
