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

static const NSInteger codingVersionNumber = 0;
static NSString *codingFileName = @"Cache";

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
        [self setupCaches];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // Check version number. This allows me to invalidate the whole cache just by incrementing the number.
    if ([aDecoder decodeIntegerForKey:@"codingVersionNumber"] == codingVersionNumber) {
        self = [super init];
        if (self) {
            _misc = [aDecoder decodeObjectForKey:@"_misc"];
            _movies = [aDecoder decodeObjectForKey:@"movies"];
            _shows = [aDecoder decodeObjectForKey:@"shows"];
            _episodes = [aDecoder decodeObjectForKey:@"episodes"];
            _images = [aDecoder decodeObjectForKey:@"images"];
            _lists = [aDecoder decodeObjectForKey:@"lists"];
            _searches = [aDecoder decodeObjectForKey:@"searches"];
            [self setupCaches];
        }
    } else {
        [FATraktCache removeCacheFile];
        self = [self init];
        DDLogWarn(@"Cache version number has changed. Rebuilding cache…");
    }
    return self;
}

- (void)setupCaches
{
    if (!_misc) {
        _misc = [[FACache alloc] initWithName:@"misc"];
    }
    
    _misc.countLimit = 20;
    _misc.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_movies) {
        _movies = [[FACache alloc] initWithName:@"movies"];
    }
    
    // Don't cache more than 50 movies
    _movies.countLimit = 50;
    _movies.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_shows) {
        _shows = [[FACache alloc] initWithName:@"shows"];
    }
    
    // Don't cache more than 50 shows
    _shows.countLimit = 50;
    _shows.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_episodes) {
        _episodes = [[FACache alloc] initWithName:@"episodes"];
    }
    
    // Don't cache more than 500 episodes
    _episodes.countLimit = 500;
    _episodes.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_images) {
        _images = [[FABigDataCache alloc] initWithName:@"images"];
    }
    
    // Don't cache more than 100 images
    _images.countLimit = 20;
    _images.totalCostLimit = FACacheCostMebibytes(100);
    _images.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_lists) {
        _lists = [[FACache alloc] initWithName:@"lists"];
    }
    
    // Don't cache more than 20 lists
    _lists.countLimit = 200;
    _lists.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_searches) {
        _searches = [[FACache alloc] initWithName:@"searches"];
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
    [aCoder encodeInteger:codingVersionNumber forKey:@"codingVersionNumber"];
}

- (BOOL)reloadFromDisk
{
    FATraktCache *newCache = [FATraktCache cacheFromDisk];
    _misc = newCache.misc;
    _movies = newCache.movies;
    _shows = newCache.shows;
    _episodes = newCache.episodes;
    _images = newCache.images;
    _lists = newCache.lists;
    _searches = newCache.searches;
    [self setupCaches];
    return !!newCache;
}

+ (NSString *)filePath
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList  objectAtIndex:0];
    
    return [myPath stringByAppendingPathComponent:codingFileName];
}

+ (long long)fileSize
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[FATraktCache filePath] error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber longLongValue];
}

+ (id)cacheFromDisk
{
    FATraktCache *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[FATraktCache filePath]];
    DDLogInfo(@"Loading cache. File size: %.3fMB", ((double)[FATraktCache fileSize] / 1024 / 1024));
    [cache.images oldestObjectInCache];
    return cache;
}

+ (BOOL)removeCacheFile
{
    return [[NSFileManager defaultManager] removeItemAtPath:[FATraktCache filePath] error:nil];
}

- (BOOL)saveToDisk
{
    BOOL worked = [NSKeyedArchiver archiveRootObject:self toFile:[FATraktCache filePath]];
    
    DDLogInfo(@"Saving cache. File size: %.3fMB", ((double)[FATraktCache fileSize] / 1024 / 1024));
    return worked;
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
        traktCache = [FATraktCache cacheFromDisk];
        if (!traktCache) {
            traktCache = [[FATraktCache alloc] init];
        }
    });
    return traktCache;
}

@end
