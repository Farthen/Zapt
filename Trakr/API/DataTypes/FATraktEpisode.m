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
        self.detailLevel = FATraktDetailLevelMinimal;
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

- (FATraktContentType)contentType
{
    return FATraktContentTypeEpisodes;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktEpisode %p S%02iE%02i: \"%@\" Show: \"%@\">", self, self.season.intValue, self.episode.intValue, self.title, self.show.title];
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"number"] || [key isEqualToString:@"num"]) {
        // Stupid watchlist API calls this "number" instead of "episode", the progress api calls this "num"
        [self mapObject:object toPropertyWithKey:@"episode"];
    } else {
        [super mapObject:object toPropertyWithKey:key];
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
    return [NSString stringWithFormat:@"FATraktEpisode&%@&season=%@&episode=%@", showKey, self.season.stringValue, self.episode.stringValue];
}

- (void)commitToCache
{
    FATraktCache *cache = [FATraktCache sharedInstance];
    [cache.episodes setObject:self forKey:self.cacheKey];
}

@end
