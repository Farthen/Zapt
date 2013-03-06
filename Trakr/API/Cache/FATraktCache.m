//
//  FATraktCache.m
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCache.h"

@implementation FATraktCache
@synthesize movies = _movies;
@synthesize shows = _shows;
@synthesize episodes = _episodes;
@synthesize images = _images;

- (id)init
{
    self = [super init];
    if (self) {
        _movies = [[NSCache alloc] init];
        // Don't cache more than 50 movies
        [_movies setCountLimit:50];
        
        _shows = [[NSCache alloc] init];
        // Don't cache more than 50 shows
        [_shows setCountLimit:50];

        _episodes = [[NSCache alloc] init];
        // Don't cache more than 500 episodes
        [_episodes setCountLimit:500];

        _images = [[NSCache alloc] init];
        // Don't cache more than 20 images
        [_images setCountLimit:20];
    }
    return self;
}

- (void)clearCaches
{
    [self.movies removeAllObjects];
    [self.shows removeAllObjects];
    [self.episodes removeAllObjects];
    [self.images removeAllObjects];
}

+ (FATraktCache *)sharedInstance
{
    static dispatch_once_t once;
    static FATraktCache *traktCache;
    dispatch_once(&once, ^ { traktCache = [[FATraktCache alloc] init]; });
    return traktCache;
}

@end
