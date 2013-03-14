//
//  FATraktMovie.m
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktMovie.h"
#import "FATraktCache.h"

@implementation FATraktMovie

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.requestedDetailedInformation = NO;
        FATraktMovie *cachedMovie = [[FATraktCache sharedInstance].movies objectForKey:self.cacheKey];
        if (cachedMovie) {
            // cache hit!
            // update the cached movie with new values
            [cachedMovie mapObjectsInDict:dict];
            // return the cached movie
            self = cachedMovie;
        }
    }
    return self;
}

- (FAContentType)contentType
{
    return FAContentTypeMovies;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktMovie %p with title: \"%@\">", self, self.title];
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"imdb=%@&title=%@&year=%@", self.imdb_id, self.title, self.year];
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(id)key
{
    [super mapObject:object ofType:propertyType toPropertyWithKey:key];
}

@end
