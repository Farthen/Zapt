//
//  FATraktSeason.m
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSeason.h"
#import "FATraktEpisode.h"

@implementation FATraktSeason {
    FATraktShow *_show;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktSeason %p season %@ of show with title: %@>", self, self.season, self.show.title];
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
    if ([key isEqualToString:@"episodes"] && propertyType.objcClass == [NSArray class] && [object isKindOfClass:[NSArray class]]) {
        NSMutableArray *episodesArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (id item in (NSArray *)object) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSDictionary *episodeDict = item;
                FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:_show];
                [episodesArray addObject:episode];
            } else if ([item isKindOfClass:[NSNumber class]]) {
                FATraktEpisode *episode = [[FATraktEpisode alloc] init];
                episode.episode = item;
                episode.season = self.season;
                episode.detailLevel = FATraktDetailLevelMinimal;
                [episodesArray addObject:episode];
            }
        }
        [self setValue:[NSArray arrayWithArray:episodesArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}


@end
