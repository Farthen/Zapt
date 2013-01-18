//
//  FATraktSeason.m
//  Trakr
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
    return [NSString stringWithFormat:@"<FATraktSeason %@ of show with title: %@>", self.season, self.show.title];
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

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"episodes"] && [propertyType isEqualToString:@"NSArray"] && [object isKindOfClass:[NSArray class]]) {
        NSMutableArray *episodesArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *episodeDict in (NSArray *)object) {
            FATraktEpisode *episode = [[FATraktEpisode alloc] initWithJSONDict:episodeDict andShow:_show];
            [episodesArray addObject:episode];
        }
        [self setValue:[NSArray arrayWithArray:episodesArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}


@end
