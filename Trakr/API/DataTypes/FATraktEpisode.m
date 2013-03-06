//
//  FATraktEpisode.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktEpisode.h"
#import "FATraktShow.h"
#import "FATraktCache.h"

@implementation FATraktEpisode

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.requestedDetailedInformation = NO;        
    }
    return self;
}

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    self = [self initWithJSONDict:dict];
    if (self) {
        self.show = show;
        
        FATraktEpisode *cachedEpisode = [[FATraktCache sharedInstance].episodes objectForKey:self.cacheKey];
        if (cachedEpisode) {
            // cache hit!
            // update the cached episode with new values
            [cachedEpisode mapObjectsInDict:dict];
            // return the cached episode
            self = cachedEpisode;
        }
    }
    return self;
}

- (FAContentType)contentType
{
    return FAContentTypeEpisodes;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktEpisode S%02iE%02i: \"%@\" Show: \"%@\">", self.season.intValue, self.episode.intValue, self.title, self.show.title];
}

- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"number"]) {
        // Stupid watchlist API calls this "number" instead of "episode"
        [self mapObject:object ofType:propertyType toPropertyWithKey:@"episode"];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (NSString *)cacheKey
{
    NSString *showKey;
    if (!self.show) {
        // If the show is unavailable for some reason, generate a UUID to avoid collisions
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        showKey = uuidStr;
    } else {
        showKey = self.show.cacheKey;
    }
    return [NSString stringWithFormat:@"%@&season=%@&episode=%@", showKey, self.season.stringValue, self.episode.stringValue];
}

@end
