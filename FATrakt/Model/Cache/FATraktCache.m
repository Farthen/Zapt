//
//  FATraktCache.m
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCache.h"
#import "Misc.h"
#import "TMFastCache.h"
#import "FAGlobalSettings.h"

NSString *FATraktCacheClearedNotification = @"FATraktCacheClearedNotification";
static NSInteger __cacheVersionNumber = 5;

@interface FATraktCache ()
@property NSLock *lock;
@end

@implementation FATraktCache
@synthesize misc = _misc;
@synthesize content = _content;
@synthesize images = _images;
@synthesize lists = _lists;
@synthesize searches = _searches;
@synthesize calendar = _calendar;

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

- (void)setupCaches
{
    
    if (!_misc) {
        _misc = [[TMFastCache alloc] initWithName:@"misc"];
    }
    
    if (!_content) {
        _content = [[TMFastCache alloc] initWithName:@"content"];
    }
    
    if (!_images) {
        _images = [[TMFastCache alloc] initWithName:@"images"];
        _images.memoryCache.ageLimit = 60;
    }
    
    if (!_lists) {
        _lists = [[TMFastCache alloc] initWithName:@"lists"];
    }
    
    if (!_searches) {
        _searches = [[TMFastCache alloc] initWithName:@"searches"];
        _searches.memoryCache.ageLimit = 60;
    }
    
    if (!_calendar) {
        _calendar = [[TMFastCache alloc] initWithName:@"calendar"];
    }
    
    NSInteger cacheVersionNumber = [[FAGlobalSettings sharedInstance].userDefaults integerForKey:@"cacheVersionNumber"];
    if (cacheVersionNumber != __cacheVersionNumber) {
        [self clearCaches];
        
        [[FAGlobalSettings sharedInstance].userDefaults setInteger:__cacheVersionNumber forKey:@"cacheVersionNumber"];
    }
    
    [self trimCaches];
}

- (void)trimCaches
{
    NSDate *trimDate = [NSDate dateWithTimeIntervalSinceNow:- FATimeIntervalWeeks(4)];
    
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
    
    DDLogDebug(@"Cleared all Caches");
}

- (void)commitAllCaches
{
    for (TMFastCache *cache in self.allCaches) {
        [cache commitAllObjects];
    }
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
        [[FAGlobalSettings sharedInstance].userDefaults setBool:YES forKey:@"migrationRemovedFACache"];
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
