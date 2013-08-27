//
//  FABigDataCache.m
//  Trakr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FABigDataCache.h"
#import "NSObject+PerformBlock.h"

@implementation FABigDataCache

// commits all data to the backing cache
- (void)commitAllItemsToPersistentStorage
{
    for (id item in _cachedItems) {
        if (![item isMemberOfClass:[NSNull class]]) {
            FABigDataCachedItem *cachedItem = item;
            if (cachedItem.dirty) {
                [cachedItem commitToPersistentStorage];
            }
        }
    }
}

- (NSUInteger)loadedObjectCount
{
    NSUInteger count = 0;
    for (id key in _cachedItems) {
        id item = [_cachedItems objectForKey:key];
        if ([item isKindOfClass:[FABigDataCachedItem class]]) {
            if (![item isContentDiscarded]) {
                count++;
            }
        }
    }
    return count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FABigDataCache with name: \"%@\", object count: %i (loaded)/%i (total), total cost:%i>", self.name, self.loadedObjectCount, self.objectCount, self.totalCost];
}

- (void)purgeAllItemsFromPersistentStorage
{
    [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:nil];
}

- (NSString *)filePath
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList objectAtIndex:0];
    myPath = [myPath stringByAppendingPathComponent:self.name];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return myPath;
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost expirationTime:(NSTimeInterval)expirationTime
{
    if (obj == nil) {
        return;
    }
    FABigDataCachedItem *item = [[FABigDataCachedItem alloc] initWithCache:self key:key object:obj];
    item.expirationTime = expirationTime;
    item.cost = cost;
    item.dirty = YES;
    
    [super backingCacheSetObject:item forKey:key cost:cost];
    [_cachedItems setObject:item forKey:key];
    
    DDLogModel(@"Adding object %@ with key: %@ to cache: \"%@\", new object count: %i", [obj description], key, self.name, self.objectCount);
}

- (void)cleanObjectFromMemoryForKey:(id)key
{
    id item = [super objectForKey:key];
    if ([item isKindOfClass:[NSNull class]]) {
        return;
    }
    
    FABigDataCachedItem *cacheItem = item;
    [cacheItem purgeFromPersistentStorage];
}

@end

@implementation FABigDataCachedItem {
    NSInteger _accessCount;
}

- (instancetype)initWithCache:(FACache *)cache key:(id)key object:(id)object
{
    self = [super initWithCache:cache key:key object:object];
    if (self) {
        // Access object to force it to be purged if not "retained"
        [self object];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _accessCount = 0;
    }
    return self;
}

- (NSString *)filename
{
    return [((FABigDataCache *)_cache).filePath stringByAppendingPathComponent:self.cacheKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _accessCount = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self commitToPersistentStorage];
    [self purgeDataFromMemory];
    [super encodeWithCoder:aCoder];
}

- (id)object
{
    [self beginContentAccess];
    id object = _object;
    // FIXME: This is needed to ensure an "autoreleased" kind of behavior, that will time out the access after some time
    // At the moment set to 30 seconds
    [self performBlock:^{
        [self endContentAccess];
    } afterDelay:30];
    return object;
}

- (BOOL)beginContentAccess
{
    _accessCount++;
    self.dirty = YES;
    return [self loadDataFromPersistentStorage];
}

- (void)endContentAccess
{
    _accessCount--;
    [self discardContentIfPossible];
}

- (void)discardContentIfPossible
{
    if (_accessCount <= 0) {
        _accessCount = 0;
        if (self.dirty) {
            [self commitToPersistentStorage];
        }
        [self purgeDataFromMemory];
    }
}

- (BOOL)isContentDiscarded
{
    BOOL discarded = _object == nil;
    return discarded;
}

- (void)purgeDataFromMemory
{
    [self commitToPersistentStorage];
    _object = nil;
}

- (BOOL)loadDataFromPersistentStorage
{
    if (_object == nil) {
        _object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
    }
    return _object != nil;
}

- (void)commitToPersistentStorage
{
    if (_object != nil) {
        if ([NSKeyedArchiver archiveRootObject:_object toFile:[self filename]]) {
            self.dirty = NO;
        }
    }
}

- (void)purgeFromPersistentStorage
{
    [[NSFileManager defaultManager] removeItemAtPath:[self filename] error:nil];
}

@end