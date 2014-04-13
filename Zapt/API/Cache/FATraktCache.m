//
//  FATraktCache.m
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCache.h"
#import "Misc.h"

NSString *FATraktCacheClearedNotification = @"FATraktCacheClearedNotification";
static NSInteger __cacheVersionNumber = 3;

@interface FATraktCache ()
@property NSLock *lock;
@end

@implementation FATraktCache
@synthesize misc = _misc;
@synthesize content = _content;
@synthesize images = _images;
@synthesize lists = _lists;
@synthesize searches = _searches;

+ (void)initialize
{
    //[FACache setCodingVersionNumber:18];
}

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
        _content = [aDecoder decodeObjectForKey:@"content"];
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
        _misc = [[TMCache alloc] initWithName:@"misc"];
    }
    
    if (!_content) {
        _content = [[TMCache alloc] initWithName:@"content"];
    }
    
    if (!_images) {
        _images = [[TMCache alloc] initWithName:@"images"];
        _images.memoryCache.ageLimit = 60;
    }
    
    if (!_lists) {
        _lists = [[TMCache alloc] initWithName:@"lists"];
    }
    
    if (!_searches) {
        _searches = [[TMCache alloc] initWithName:@"searches"];
        _searches.memoryCache.ageLimit = 60;
    }
    
    NSInteger cacheVersionNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"cacheVersionNumber"];
    if (cacheVersionNumber != __cacheVersionNumber) {
        [self clearCaches];
        
        [[NSUserDefaults standardUserDefaults] setInteger:__cacheVersionNumber forKey:@"cacheVersionNumber"];
    }
    
    [self trimCaches];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_misc forKey:@"misc"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_lists forKey:@"lists"];
    [aCoder encodeObject:_searches forKey:@"searches"];
}

- (void)trimCaches
{
    NSDate *trimDate = [NSDate dateWithTimeIntervalSinceNow:FATimeIntervalWeeks(4)];
    
    [_misc trimToDate:trimDate block:nil];
    [_content trimToDate:trimDate block:nil];
    [_images trimToDate:trimDate block:nil];
    [_lists trimToDate:trimDate block:nil];
    [_searches trimToDate:trimDate block:nil];
}

- (void)clearCaches
{
    dispatch_semaphore_t cacheSemaphore = dispatch_semaphore_create(0);
    
    [self clearCachesCallback:^{
        dispatch_semaphore_signal(cacheSemaphore);
    }];
    
    dispatch_semaphore_wait(cacheSemaphore, DISPATCH_TIME_FOREVER);
}

- (void)clearCachesCallback:(void (^)(void))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (TMCache *cache in self.allCaches) {
            [cache removeAllObjects];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FATraktCacheClearedNotification object:self];
        
        if (callback) {
            callback();
        }
    });
    
    DDLogModel(@"Cleared all Caches");
}

- (void)migrationRemoveFACache
{
    // Removes everything that is left of FACache from older versions
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [myPathList objectAtIndex:0];
    
    NSMutableArray *pathsToRemove = [NSMutableArray array];
    
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"FACache-content"]];
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"FACache-images"]];
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"FACache-lists"]];
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"FACache-misc"]];
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"FACache-searches"]];
    [pathsToRemove addObject:[cacheDir stringByAppendingPathComponent:@"images"]];
    
    NSError *error = nil;
    
    for (NSString *path in pathsToRemove) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    
    if (!error) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"migrationRemovedFACache"];
    }
}

- (NSArray *)allCaches
{
    return @[self.misc, self.content, self.images, self.lists, self.searches];
}

+ (FATraktCache *)sharedInstance
{
    static dispatch_once_t once;
    static FATraktCache *traktCache;
    dispatch_once(&once, ^{
        traktCache = [[FATraktCache alloc] init];
    });
    
    return traktCache;
}

@end
