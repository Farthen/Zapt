//
//  FATraktMovie.m
//  Zapr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktMovie.h"
#import "FATraktCache.h"

@implementation FATraktMovie
@synthesize shouldBeCached;

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.detailLevel = FATraktDetailLevelMinimal;
        FATraktMovie *cachedMovie = [self.class.backingCache objectForKey:self.cacheKey];
        if (cachedMovie) {
            // cache hit!
            // update the cached movie with new values
            [cachedMovie mapObjectsInDict:dict];
            // return the cached movie
            self = cachedMovie;
        }
        [self commitToCache];
    }
    return self;
}

- (FATraktContentType)contentType
{
    return FATraktContentTypeMovies;
}

- (NSString *)urlIdentifier
{
    if (self.imdb_id) {
        return self.imdb_id;
    } else if (self.tmdb_id) {
        return self.tmdb_id;
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
    
    if (self.title) {
        [dict setObject:self.title forKey:@"title"];
    }
    
    if (self.year) {
        [dict setObject:self.year forKey:@"year"];
    }
    
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktMovie %p with title: \"%@\">", self, self.title];
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktMovie&imdb=%@&title=%@&year=%@", self.imdb_id, self.title, self.year];
}

+ (FACache *)backingCache
{
    return FATraktCache.sharedInstance.movies;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(id)key
{
    [super mapObject:object ofType:propertyType toPropertyWithKey:key];
}

@end
