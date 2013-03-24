//
//  FATraktShow.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktShow.h"
#import "FATraktSeason.h"
#import "FATraktCache.h"

@implementation FATraktShow

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.detailLevel = FATraktDetailLevelMinimal;
        FATraktShow *cachedShow = [[FATraktCache sharedInstance].shows objectForKey:self.cacheKey];
        if (cachedShow) {
            // cache hit!
            // update the cached show with new values
            [cachedShow mapObjectsInDict:dict];
            // return the cached show
            self = cachedShow;
        }
    }
    return self;
}

- (FATraktContentType)contentType
{
    return FATraktContentTypeShows;
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

- (void)commitToCache
{
    FATraktCache *cache = [FATraktCache sharedInstance];
    [cache.shows setObject:self forKey:self.cacheKey];
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"seasons"] && propertyType.objcClass == [NSArray class] && [object isKindOfClass:[NSArray class]]) {
        NSMutableArray *seasonArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *seasonDict in (NSArray *)object) {
            FATraktSeason *season = [[FATraktSeason alloc] initWithJSONDict:seasonDict andShow:self];
            [seasonArray addObject:season];
        }
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"season" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [seasonArray sortUsingDescriptors:sortDescriptors];
        [self setValue:[NSArray arrayWithArray:seasonArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}


@end
