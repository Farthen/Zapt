//
//  FASearchData.m
//  Trakr
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

- (id)init
{
    self = [super init];
    if (self) {
        self.movies = [[NSMutableArray alloc] init];
        self.shows = [[NSMutableArray alloc] init];
        self.episodes = [[NSMutableArray alloc] init];
    }
    return self;
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

@end
