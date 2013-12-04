//
//  FATraktShow.m
//  Zapr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktShow.h"
#import "FATraktSeason.h"
#import "FATraktCache.h"

@interface FATraktShow ()
@property NSString *showCacheKey;
@end

@implementation FATraktShow {
    NSMutableArray *_seasons;
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

+ (FACache *)backingCache
{
    return FATraktCache.sharedInstance.content;
}

- (NSUInteger)episodeCount
{
    NSUInteger count = 0;
    for (FATraktSeason *season in self.seasons) {
        count += season.episodes.count;
    }
    return count;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"seasons"]) {
        if ([object isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *seasonArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
            for (NSDictionary *seasonDict in (NSArray *)object) {
                FATraktSeason *season = [[FATraktSeason alloc] initWithJSONDict:seasonDict andShow:self];
                [seasonArray addObject:season];
            }
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seasonNumber" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [seasonArray sortUsingDescriptors:sortDescriptors];
            
            [self setValue:[NSArray arrayWithArray:seasonArray] forKey:key];
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (void)setSeasons:(NSMutableArray *)seasons
{
    _seasons = seasons;
}

- (NSMutableArray *)seasons
{
    if (!_seasons) {
        if (self.seasonCacheKeys) {
            _seasons = [self.seasonCacheKeys mapUsingBlock:^id(id obj, NSUInteger idx) {
                FATraktSeason *season = [FATraktSeason.backingCache objectForKey:obj];
                
                if (!season) {
                    season = [[FATraktSeason alloc] init];
                    season.seasonNumber = [NSNumber numberWithUnsignedInteger:idx];
                }
                
                return season;
            }];
            
            for (FATraktSeason *season in [_seasons copy]) {
                season.show = self;
            }
        }
    }
    
    return _seasons;
}

- (void)setSeasonCacheKeys:(NSArray *)seasonCacheKeys
{
    _seasonCacheKeys = seasonCacheKeys;
}

- (NSArray *)seasonCacheKeys
{
    if (_seasons) {
        return [_seasons valueForKey:@"cacheKey"];
    }
    
    return _seasonCacheKeys;
}


@end
