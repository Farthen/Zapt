//
//  FATraktCache.m
//  Zapr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCache.h"
#import "Misc.h"


#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_INFO

@interface FATraktCache ()
@property NSLock *lock;
@end

@implementation FATraktCache
@synthesize misc = _misc;
@synthesize movies = _movies;
@synthesize shows = _shows;
@synthesize episodes = _episodes;
@synthesize images = _images;
@synthesize lists = _lists;
@synthesize searches = _searches;

- (id)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        [self setupCaches];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _misc = [aDecoder decodeObjectForKey:@"_misc"];
        _movies = [aDecoder decodeObjectForKey:@"movies"];
        _shows = [aDecoder decodeObjectForKey:@"shows"];
        _episodes = [aDecoder decodeObjectForKey:@"episodes"];
        _images = [aDecoder decodeObjectForKey:@"images"];
        _lists = [aDecoder decodeObjectForKey:@"lists"];
        _searches = [aDecoder decodeObjectForKey:@"searches"];
        self.lock = [[NSLock alloc] init];
        [self setupCaches];
    }

    return self;
}

- (void)setupCaches
{
    if (!_misc) {
        _misc = [[FACache alloc] initWithName:@"misc" loadFromDisk:YES];
        _misc.delegate = self;
    }
    
    _misc.countLimit = 20;
    _misc.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_movies) {
        _movies = [[FACache alloc] initWithName:@"movies" loadFromDisk:YES];
        _movies.delegate = self;
    }
    
    // Don't cache more than 50 movies
    _movies.countLimit = 50;
    _movies.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_shows) {
        _shows = [[FACache alloc] initWithName:@"shows" loadFromDisk:YES];
        _shows.delegate = self;
    }
    
    // Don't cache more than 50 shows
    _shows.countLimit = 50;
    _shows.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_episodes) {
        _episodes = [[FACache alloc] initWithName:@"episodes" loadFromDisk:YES];
        _episodes.delegate = self;
    }
    
    // Don't cache more than 500 episodes
    _episodes.countLimit = 500;
    _episodes.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_images) {
        _images = [[FABigDataCache alloc] initWithName:@"images" loadFromDisk:YES];
        _images.delegate = self;
    }
    
    // Don't cache more than 100 images
    _images.countLimit = 20;
    _images.totalCostLimit = FACacheCostMebibytes(100);
    _images.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_lists) {
        _lists = [[FACache alloc] initWithName:@"lists" loadFromDisk:YES];
        _lists.delegate = self;
    }
    
    // Don't cache more than 20 lists
    _lists.countLimit = 200;
    _lists.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_searches) {
        _searches = [[FACache alloc] initWithName:@"searches" loadFromDisk:YES];
        _searches.delegate = self;
    }
    
    // Don't cache more than 100 search results
    _searches.countLimit = 100;
    _searches.defaultExpirationTime = NSTimeIntervalOneWeek;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_misc forKey:@"misc"];
    [aCoder encodeObject:_movies forKey:@"movies"];
    [aCoder encodeObject:_shows forKey:@"shows"];
    [aCoder encodeObject:_episodes forKey:@"episodes"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_lists forKey:@"lists"];
    [aCoder encodeObject:_searches forKey:@"searches"];
}

- (void)clearCaches
{
    [self.misc removeAllObjects];
    [self.movies removeAllObjects];
    [self.shows removeAllObjects];
    [self.episodes removeAllObjects];
    [self.images removeAllObjects];
    [self.lists removeAllObjects];
    [self.searches removeAllObjects];
}

+ (FATraktCache *)sharedInstance
{
    static dispatch_once_t once;
    static FATraktCache *traktCache;
    dispatch_once(&once, ^ {
        traktCache = [[FATraktCache alloc] init];
    });
    return traktCache;
}

@end
