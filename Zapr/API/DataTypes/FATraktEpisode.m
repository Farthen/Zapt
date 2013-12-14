//
//  FATraktEpisode.m
//  Zapr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktEpisode.h"
#import "FATraktShow.h"
#import "FATraktCache.h"
#import "FATraktImageList.h"
#import "FATraktSeason.h"

@implementation FATraktEpisode {
    __weak FATraktShow *_show;
    NSString *_showCacheKey;
    
    __weak FATraktSeason *_season;
    NSString *_seasonCacheKey;
}

- (instancetype)initWithShow:(FATraktShow *)show seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber
{
    self = [super init];
    
    if (self) {
        self.seasonNumber = seasonNumber;
        self.episodeNumber = episodeNumber;
        _show = show;
    }
    
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.detailLevel = FATraktDetailLevelDefault;
    }
    
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    self = [self initWithJSONDict:dict];
    
    if (self) {
        self.show = show;
        
        FATraktEpisode *cachedEpisode = [self.class.backingCache objectForKey:self.cacheKey];
        
        if (cachedEpisode) {
            // cache hit!
            // update the cached episode with new values
            [cachedEpisode mapObjectsInDict:dict];
            // return the cached episode
            self = cachedEpisode;
        }
        
        [self commitToCache];
        [self.show commitToCache];
    }
    
    return self;
}

- (instancetype)initWithSummaryDict:(NSDictionary *)dict
{
    self = [self initWithJSONDict:[dict objectForKey:@"episode"]];
    
    if (self) {
        self.show = [[FATraktShow alloc] initWithJSONDict:[dict objectForKey:@"show"]];
    }
    
    return self;
}

- (void)mapObjectsInSummaryDict:(NSDictionary *)dict
{
    [self mapObjectsInDict:[dict objectForKey:@"episode"]];
    [self.show mapObjectsInDict:[dict objectForKey:@"show"]];
}

- (FATraktEpisode *)nextEpisode
{
    FATraktSeason *thisSeason = [self.show seasonWithID:self.seasonNumber.unsignedIntegerValue];
    FATraktEpisode *nextEpisode = [thisSeason episodeWithID:self.episodeNumber.unsignedIntegerValue + 1];
    
    if (!nextEpisode) {
        FATraktSeason *nextSeason = [self.show seasonWithID:self.seasonNumber.unsignedIntegerValue + 1];
        nextEpisode = [nextSeason episodeWithID:1];
    }
    
    return nextEpisode;
}

- (FATraktContentType)contentType
{
    return FATraktContentTypeEpisodes;
}

- (NSString *)urlIdentifier
{
    NSString *showIdentifier = self.show.urlIdentifier;
    
    if (showIdentifier) {
        if (self.seasonNumber && self.episodeNumber) {
            return [NSString stringWithFormat:@"%@/%@/%@", showIdentifier, self.seasonNumber, self.episodeNumber];
        }
    }
    
    return nil;
}

- (NSDictionary *)postDictInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.episodeNumber) {
        [dict setObject:self.episodeNumber forKey:@"episode"];
    }
    
    if (self.seasonNumber) {
        [dict setObject:self.seasonNumber forKey:@"season"];
    }
    
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktEpisode %p S%02iE%02i: \"%@\" Show: \"%@\">", self, self.seasonNumber.intValue, self.episodeNumber.intValue, self.title, self.show.title];
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"number"] || [key isEqualToString:@"num"]) {
        // Stupid watchlist API calls this "number" instead of "episode", the progress api calls this "num"
        [self mapObject:object toPropertyWithKey:@"episode"];
    } else if ([key isEqualToString:@"episode"]) {
        [self mapObject:object toPropertyWithKey:@"episodeNumber"];
    } else if ([key isEqualToString:@"season"]) {
        [self mapObject:object toPropertyWithKey:@"seasonNumber"];
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObjects:@"show", @"season", nil];
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
    
    return [NSString stringWithFormat:@"FATraktEpisode&%@&season=%@&episode=%@", showKey, self.seasonNumber.stringValue, self.episodeNumber.stringValue];
}

+ (FACache *)backingCache
{
    return FATraktCache.sharedInstance.content;
}

- (NSString *)widescreenImageURL
{
    if (self.images.screen) {
        return self.images.screen;
    } else {
        return self.show.images.fanart;
    }
}

- (void)setShow:(FATraktShow *)show
{
    _show = show;
    
    // See the implementation in FATraktSeason: We prevent a retain loop here
    if (show) {
        FATraktSeason *season;
        
        if (show.seasons && show.seasons.count > self.seasonNumber.unsignedIntegerValue) {
            season = show.seasons[self.seasonNumber.unsignedIntegerValue];
        } else {
            season = [[FATraktSeason alloc] initWithShow:show seasonNumber:self.seasonNumber];
        }
        
        // This will insert itself into the show.seasons array
        season.show = show;
        
        // This will stay retained because it is in the show.seasons array
        // This will also insert the episode into the season.episodes array
        self.season = season;
        
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

- (void)setSeason:(FATraktSeason *)season
{
    _season = season;
    
    if (season) {
        if (!season.episodes) {
            season.episodes = [NSMutableArray array];
        }
        
        // - 1 because episode numbers start at 1
        while ((NSInteger)season.episodes.count < (NSInteger)self.episodeNumber.unsignedIntegerValue - 1) {
            // -1 because index. +1 because episode numbers start at 1
            FATraktEpisode *episode =
            [[FATraktEpisode alloc] initWithShow:self.show
                                    seasonNumber:season.seasonNumber
                                   episodeNumber:[NSNumber numberWithUnsignedInteger:season.episodes.count - 1 + 1]];
            episode->_season = season;
            
            
            episode.detailLevel = FATraktDetailLevelMinimal;
            
            [season.episodes addObject:episode];
        }
        
        if (season.episodes.count == self.episodeNumber.unsignedIntegerValue - 1) {
            [season.episodes addObject:self];
        } else {
            // FIXME: this overrides the 0th episode if a first exists
            season.episodes[MAX(0, (NSInteger)self.episodeNumber.unsignedIntegerValue - 1)] = self;
        }
        
        [season commitToCache];
    }
}

- (FATraktSeason *)season
{
    if (!_season) {
        if (_seasonCacheKey) {
            _season = [FATraktShow.backingCache objectForKey:_seasonCacheKey];
        }
    }
    
    return _season;
}

- (void)setSeasonCacheKey:(NSString *)seasonCacheKey
{
    _seasonCacheKey = seasonCacheKey;
}

- (NSString *)seasonCacheKey
{
    if (_season) {
        return _season.cacheKey;
    }
    
    return _seasonCacheKey;
}

@end
