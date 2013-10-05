//
//  FABigDataCache.m
//  Zapr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FABigDataCache.h"
#import "NSObject+PerformBlock.h"
#import "FACache+Private.h"

@interface FABigDataCachedItem : FACachedItem

@property (assign) BOOL dirty;
@property (readonly) NSInteger accessCount;

- (BOOL)isContentDiscarded;
- (void)commitToPersistentStorage;
- (void)purgeFromPersistentStorage;

@end

@implementation FABigDataCache

// commits all data to the backing cache
- (void)commitAllItemsToPersistentStorage
{
    [self.lock lock];
    
    for (id item in self.allObjects) {
        if ([item isMemberOfClass:[FABigDataCachedItem class]]) {
            FABigDataCachedItem *cachedItem = item;
            
            if (cachedItem.dirty) {
                [cachedItem commitToPersistentStorage];
            }
        }
    }
    
    [self.lock unlock];
}

- (NSUInteger)loadedObjectCount
{
    [self.lock lock];
    
    NSUInteger count = 0;
    for (FABigDataCachedItem *item in self.allObjects) {
        if ([item isKindOfClass:[FABigDataCachedItem class]]) {
            
            if (![item isContentDiscarded]) {
                count++;
            }
        }
    }
    
    [self.lock unlock];
    return count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FABigDataCache with name: \"%@\", object count: %i (loaded)/%i (total), total cost:%i>", self.name, self.loadedObjectCount, self.objectCount, self.totalCost];
}

- (void)purgeAllItemsFromPersistentStorage
{
    [self.lock lock];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:nil];
    
    [self.lock unlock];
}

- (NSString *)filePath
{
    [self.lock lock];
    
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList objectAtIndex:0];
    myPath = [myPath stringByAppendingPathComponent:self.name];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:myPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [self.lock unlock];
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
    
    [self setCachedItem:item forKey:key];
    
    DDLogModel(@"Adding object %@ with key: %@ to cache: \"%@\", new object count: %i", [obj description], key, self.name, self.objectCount);
}

- (void)cleanObjectFromMemoryForKey:(id)key
{
    id item = [self cachedItemForKey:key];
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
    return [((FABigDataCache *)self.cache).filePath stringByAppendingPathComponent:self.cacheKey];
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
    [self.lock lock];
    
    [self commitToPersistentStorage];
    [self purgeDataFromMemory];
    [super encodeWithCoder:aCoder];
    
    [self.lock unlock];
}

- (void)discardContentIfPossible
{
    [self.lock lock];
    
    if (_accessCount <= 0) {
        _accessCount = 0;
        if (self.dirty) {
            [self commitToPersistentStorage];
        }
        [self purgeDataFromMemory];
    }
    
    [self.lock unlock];
}

- (BOOL)isContentDiscarded
{
    [self.lock lock];
    BOOL discarded = self.object == nil;
    [self.lock unlock];
    
    return discarded;
}

- (void)purgeDataFromMemory
{
    [self.lock lock];
    
    [self commitToPersistentStorage];
    self.object = nil;
    
    [self.lock unlock];
}

- (BOOL)loadDataFromPersistentStorage
{
    [self.lock lock];
    
    if (self.object == nil) {
        self.object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
    }
    
    BOOL value = self.object != nil;
    
    [self.lock unlock];
    
    return value;
}

- (void)commitToPersistentStorage
{
    [self.lock lock];
    
    if (self.object != nil) {
        if ([NSKeyedArchiver archiveRootObject:self.object toFile:[self filename]]) {
            self.dirty = NO;
        }
    }
    
    [self.lock unlock];
}

- (void)purgeFromPersistentStorage
{
    [self.lock lock];
    [[NSFileManager defaultManager] removeItemAtPath:[self filename] error:nil];
    [self.lock unlock];
}

@end
