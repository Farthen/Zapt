//
//  FATraktSeasonProgress.m
//  Zapt
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSeasonProgress.h"
#import "FATraktSeason.h"
#import "FATraktEpisode.h"

@interface FATraktSeasonProgress ()

@property (nonatomic) NSString *seasonCacheKey;

@end

@implementation FATraktSeasonProgress

- (instancetype)initWithJSONDict:(NSDictionary *)dict andSeason:(FATraktSeason *)season
{
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.season = season;
    }
    
    return self;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"season"]) {
        return;
    } else if ([key isEqualToString:@"episodes"]) {
        for (NSString *key in object) {
            
            BOOL watched = [object[key] boolValue];
            
            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithShow:self.season.show seasonNumber:self.season.seasonNumber episodeNumber:[NSNumber numberWithInteger:[key integerValue]]];
            episode.season = self.season;
            episode = [episode cachedVersion];
            
            episode.watched = watched;
            
            [self.season addEpisode:episode];
        }
    }
}

- (void)setSeason:(FATraktSeason *)season
{
    self.seasonCacheKey = season.cacheKey;
}

 -(FATraktSeason *)season
{
    return [[FATraktSeason backingCache] objectForKey:self.seasonCacheKey];
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObjects:@"season", nil];
}

@end
