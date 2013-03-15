//
//  FATraktCache.m
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCache.h"
#import "Misc.h"

static const NSInteger codingVersionNumber = 0;
static NSString *codingFileName = @"Cache";

@implementation FATraktCache
@synthesize movies = _movies;
@synthesize shows = _shows;
@synthesize episodes = _episodes;
@synthesize images = _images;
@synthesize lists = _lists;

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
            _movies = [aDecoder decodeObjectForKey:@"movies"];
            _shows = [aDecoder decodeObjectForKey:@"shows"];
            _episodes = [aDecoder decodeObjectForKey:@"episodes"];
            _images = [aDecoder decodeObjectForKey:@"images"];
            NSLog(@"total cost of images: %iKB", _images.totalCost / 1024);
            _lists = [aDecoder decodeObjectForKey:@"lists"];
            [self setupCaches];
        }
    } else {
        self = [self init];
        [APLog warning:@"Cache version number has changed. Rebuilding cache…"];
    }
    return self;
}

- (void)setupCaches
{
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
        _images = [[FACache alloc] initWithName:@"images"];
    }
    
    // Don't cache more than 100 images
    _images.countLimit = 100;
    _images.totalCostLimit = FACacheCostMebibytes(20);
    _images.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_lists) {
        _lists = [[FACache alloc] initWithName:@"lists"];
    }
    
    // Don't cache more than 20 lists
    _lists.countLimit = 20;
    _lists.defaultExpirationTime = NSTimeIntervalOneWeek;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_movies forKey:@"movies"];
    [aCoder encodeObject:_shows forKey:@"shows"];
    [aCoder encodeObject:_episodes forKey:@"episodes"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_lists forKey:@"lists"];
    [aCoder encodeInteger:codingVersionNumber forKey:@"codingVersionNumber"];
}

+ (id)cacheFromDisk
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList  objectAtIndex:0];
    
    NSString *filePath = [myPath stringByAppendingPathComponent:codingFileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

- (BOOL)saveToDisk
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList  objectAtIndex:0];
    NSString *filePath = [myPath stringByAppendingPathComponent:codingFileName];
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self toFile:filePath];
    NSLog(@"Success: %i", success);
    return success;
}

- (void)clearCaches
{
    [self.movies removeAllObjects];
    [self.shows removeAllObjects];
    [self.episodes removeAllObjects];
    [self.images removeAllObjects];
    [self.lists removeAllObjects];
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
