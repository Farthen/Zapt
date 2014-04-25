//
//  FASearchData.m
//  Zapt
//
//  Created by Finn Wilke on 04.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchData.h"

@interface FASearchData () {
    NSArray *_movies;
    NSArray *_shows;
    NSArray *_episodes;
}
@end

@implementation FASearchData

- (id)initWithSearchString:(NSString *)searchString
{
    self = [super init];
    
    if (self) {
        self.searchString = searchString;
        self.movies = [[NSMutableArray alloc] init];
        self.shows = [[NSMutableArray alloc] init];
        self.episodes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.searchString = [aDecoder decodeObjectForKey:@"searchString"];
        self.movies = [aDecoder decodeObjectForKey:@"movies"];
        self.shows = [aDecoder decodeObjectForKey:@"shows"];
        self.episodes = [aDecoder decodeObjectForKey:@"episodes"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.searchString forKey:@"searchString"];
    [aCoder encodeObject:self.movies forKey:@"movies"];
    [aCoder encodeObject:self.shows forKey:@"shows"];
    [aCoder encodeObject:self.episodes forKey:@"episodes"];
}

- (NSArray *)movies
{
    return _movies;
}

- (void)setMovies:(NSArray *)movies
{
    _movies = movies;
}

- (NSArray *)shows
{
    return _shows;
}

- (void)setShows:(NSArray *)shows
{
    _shows = shows;
}

- (NSArray *)episodes
{
    return _episodes;
}

- (void)setEpisodes:(NSArray *)episodes
{
    _episodes = episodes;
}

- (NSArray *)searchDataForContentType:(FATraktContentType)contentType
{
    if (contentType == FATraktContentTypeMovies) {
        return _movies;
    } else if (contentType == FATraktContentTypeEpisodes) {
        return _episodes;
    } else if (contentType == FATraktContentTypeShows) {
        return _shows;
    }
    
    return nil;
}

@end
