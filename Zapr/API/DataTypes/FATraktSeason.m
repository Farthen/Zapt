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

@implementation FATraktSeason {
    __weak FATraktShow *_show;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktSeason %p season %@ of show with title: %@>", self, self.seasonNumber, self.show.title];
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
                    episode.episodeNumber = item;
                    episode.seasonNumber = self.seasonNumber;
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
    }
}

- (FATraktShow *)show
{
    return _show;
}


@end
