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
@synthesize content = _content;
@synthesize images = _images;
@synthesize lists = _lists;
@synthesize searches = _searches;

+ (void)initialize
{
    [FACache setCodingVersionNumber:11];
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
        _misc = [[FACache alloc] initWithName:@"misc" loadFromDisk:YES];
        _misc.delegate = self;
    }
    
    _misc.countLimit = 20;
    _misc.defaultExpirationTime = NSTimeIntervalOneWeek;
    
    if (!_content) {
        _content = [[FACache alloc] initWithName:@"content" loadFromDisk:YES];
        _content.delegate = self;
    }
    
    // Don't cache more than 500 content things
    _content.countLimit = 50;
    _content.defaultExpirationTime = NSTimeIntervalOneWeek;
    
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
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_lists forKey:@"lists"];
    [aCoder encodeObject:_searches forKey:@"searches"];
}

- (void)clearCaches
{
    for (FACache *cache in self.allCaches) {
        [cache removeAllObjects];
        [cache saveToDisk];
    }
    
    DDLogModel(@"Cleared all Caches");
}

- (NSArray *)allCaches
{
    return @[self.misc, self.content, self.images, self.lists, self.searches];
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
