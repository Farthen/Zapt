//
//  FATraktShow.m
//  Zapt
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktShow.h"
#import "FATraktSeason.h"
#import "FATraktCache.h"
#import "FATraktShowProgress.h"

@interface FATraktShow ()
@property NSString *showCacheKey;
@end

@implementation FATraktShow {
    NSArray *_seasonCacheKeys;
}

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.detailLevel = FATraktDetailLevelMinimal;
        FATraktShow *cachedShow = [self.class.backingCache objectForKey:self.cacheKey];
        
        if (cachedShow) {
            // cache hit!
            // merge the two
            [cachedShow mergeWithObject:self];
            //[cachedShow mapObjectsInDict:dict];
            // return the cached show
            self = cachedShow;
        }
        
        [self commitToCache];
    }
    
    return self;
}

- (FATraktContentType)contentType
{
    return FATraktContentTypeShows;
}

- (NSString *)urlIdentifier
{
    if (self.tvdb_id) {
        return self.imdb_id;
    } else if (self.slug) {
        return self.slug;
    }
    
    return nil;
}

- (NSDictionary *)postDictInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.imdb_id) {
        [dict setObject:self.imdb_id forKey:@"imdb_id"];
    }
    
    if (self.tvdb_id) {
        [dict setObject:self.tvdb_id forKey:@"tvdb_id"];
    }
    
    if (self.title) {
        [dict setObject:self.title forKey:@"title"];
    }
    
    if (self.year) {
        [dict setObject:self.year forKey:@"year"];
    }
    
    return dict;
}

- (FATraktSeason *)seasonWithID:(NSUInteger)seasonID
{
    for (FATraktSeason *season in self.seasons) {
        if (season.seasonNumber.unsignedIntegerValue == seasonID) {
            return season;
        }
    }
    
    return nil;
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObject:@"seasons"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktShow %p with title: %@>", self, self.title];
}

- (NSString *)cacheKey
{
    NSString *key = [NSString stringWithFormat:@"FATraktShow&tvdb=%@&title=%@&year=%@", self.tvdb_id, self.title, self.year];
    
    return key;
}

+ (TMCache *)backingCache
{
    return FATraktCache.sharedInstance.content;
}

- (NSUInteger)episodeCount
{
    NSUInteger count = 0;
    
    for (FATraktSeason *season in[self.seasons copy]) {
        count += season.episodes.count;
    }
    
    return count;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"seasons"]) {
        if ([object isKindOfClass:[NSArray class]]) {
            for (NSDictionary *seasonDict in object) {
                FATraktSeason *season = [[FATraktSeason alloc] initWithJSONDict:seasonDict andShow:self];
                [self addSeason:season];
            }
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (NSArray *)seasons
{
    if (!self.seasonsDict) {
        if (self.seasonCacheKeys) {
            for (NSString *key in self.seasonCacheKeys) {
                FATraktSeason *season = [FATraktSeason.backingCache objectForKey:key];
                
                if (season && season.seasonNumber) {
                    season.show = self;
                    self.seasonsDict[season.seasonNumber] = season;
                }
            }
        }
    }
    
    return [self.seasonsDict.allValues sortedArrayUsingKey:@"seasonNumber" ascending:YES];
}

- (void)setSeasonCacheKeys:(NSArray *)seasonCacheKeys
{
    _seasonCacheKeys = seasonCacheKeys;
}

- (NSArray *)seasonCacheKeys
{
    if (!_seasonCacheKeys) {
        return [self.seasonsDict.allValues valueForKey:@"cacheKey"];
    }
    
    return _seasonCacheKeys;
}

- (void)addSeason:(FATraktSeason *)season
{
    if (!self.seasonsDict) {
        self.seasonsDict = [NSMutableDictionary dictionary];
    }
    
    if (season.seasonNumber) {
        FATraktSeason *oldSeason = self.seasonsDict[season.seasonNumber];
        
        if (oldSeason) {
            [season mergeWithObject:oldSeason];
        }
        
        self.seasonsDict[season.seasonNumber] = season;
    }
}

- (FATraktSeason *)seasonForNumber:(NSNumber *)seasonNumber
{
    return self.seasonsDict[seasonNumber];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self seasonForNumber:[NSNumber numberWithUnsignedInteger:index]];
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([key isKindOfClass:[NSNumber class]]) {
        return [self seasonForNumber:key];
    }
    
    [NSException raise:NSInternalInconsistencyException format:@"- (id)objectForKeyedSubscript: expected an NSNumber as key but got: %@", key];
    
    return nil;
}

@end
