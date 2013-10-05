//
//  FACache.m
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"
#import "FACache+Private.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_ERROR

@interface FACache ()
@property NSMutableDictionary *cachedItems;
@end

@implementation FACache

- (id)init
{
    self = [super init];
    if (self) {
        self.cachedItems = [[NSMutableDictionary alloc] init];
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"FACacheLock";
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(removeAllTimers) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(reloadAllTimers) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (id)initWithName:(NSString *)name
{
    self = [self init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.defaultExpirationTime = [aDecoder decodeDoubleForKey:@"defaultExpirationTime"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
        NSMutableDictionary *cachedItems = [aDecoder decodeObjectForKey:@"cachedItems"];
        self.cachedItems = cachedItems;
        
        DDLogModel(@"FACache \"%@\" loaded from coder. Keys: %@", self.name, self.allKeys);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.lock lock];
    
    [aCoder encodeDouble:self.defaultExpirationTime forKey:@"defaultExpirationTime"];
    [aCoder encodeObject:self.name forKey:@"name"];
    
    [aCoder encodeObject:self.cachedItems forKey:@"cachedItems"];
    
    [self.lock unlock];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACache with name: \"%@\", object count: %i, total cost:%i>", self.name, self.objectCount, self.totalCost];
}

- (void)removeExpirationDataForKey:(id)key
{
    FACachedItem *item = [self cachedItemForKey:key];
    [item removeExpirationData];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key
{
    FACachedItem *item = [self cachedItemForKey:key];
    [item setExpirationTime:expirationTime];
}

- (void)checkExpirationDateForKey:(id)key
{
    FACachedItem *item = [self cachedItemForKey:key];
    if ([item objectHasExpired]) {
        [self removeObjectForKey:key];
    }
}

- (void)timerElapsedForKey:(id)key
{
    [self checkExpirationDateForKey:key];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost expirationTime:(NSTimeInterval)expirationTime
{
    if (obj == nil) {
        return;
    }
    
    FACachedItem *item = [[FACachedItem alloc] initWithCache:self key:key object:obj];
    item.expirationTime = expirationTime;
    item.cost = cost;
    
    // this is already thread-safe
    [self setCachedItem:item forKey:key];
    
    DDLogModel(@"Adding object %@ with key: %@ to cache: \"%@\", new object count: %i", [obj description], key, self.name, self.objectCount);
}

- (void)setObject:(id)obj forKey:(id)key expirationTime:(NSTimeInterval)expirationTime
{
    [self setObject:obj forKey:key cost:0 expirationTime:expirationTime];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost
{
    [self setObject:obj forKey:key cost:cost expirationTime:self.defaultExpirationTime];
}

- (void)setObject:(id)obj forKey:(id)key
{
    [self setObject:obj forKey:key cost:0];
}

- (void)removeObjectForKey:(id)key
{
    [self removeCachedItemForKey:key];
}

- (void)removeAllTimers
{
    [self.lock lock];
    
    for (id key in self.cachedItems) {
        FACachedItem *item = [self.cachedItems objectForKey:key];
        [item removeTimer];
    }
    
    [self.lock unlock];
}

- (NSArray *)indexes
{
    [self.lock lock];
    
    NSArray *indexes = self.cachedItems.allKeys;
    
    [self.lock unlock];
    return indexes;
}

- (NSUInteger)totalCost
{
    NSUInteger totalCost = 0;
    
    [self.lock lock];
    
    for (id key in self.cachedItems) {
        FACachedItem *item = [self.cachedItems objectForKey:key];
        
        totalCost += item.cost;
    }
    
    [self.lock unlock];
    return totalCost;
}

- (NSArray *)allKeys
{
    [self.lock lock];
    NSArray *allKeys = self.cachedItems.allKeys;
    [self.lock unlock];
    
    return allKeys;
}


- (NSUInteger)objectCount
{
    [self.lock lock];
    
    NSUInteger count = self.cachedItems.count;
    
    [self.lock unlock];
    return count;
}

- (void)evictItemsIfNeeded
{
    NSInteger itemsToRemove = 0;
    
    if (self.countLimit > 0) {
        itemsToRemove = self.cachedItemCount - self.countLimit;
    }
    
    NSInteger itemCostToReduce = 0;
    if (self.totalCostLimit > 0) {
        itemCostToReduce = self.totalCost - self.totalCostLimit;
    }
    
    if (itemsToRemove > 0 ||
        itemCostToReduce > 0) {
        
        [self.lock lock];
        
        NSArray *sortedItems = [self cachedItemsSortedByAge];
        
        NSUInteger itemCount = sortedItems.count;
        for (NSUInteger i = 0; i < itemCount; i++) {
            FACachedItem *item = sortedItems[i];
            [self removeObjectForKey:item.cacheKey];
            
            itemsToRemove -= 1;
            itemCostToReduce -= item.cost;
            
            if (itemsToRemove <= 0 &&
                itemCostToReduce <= 0) {
                break;
            }
        }
        
        [self.lock unlock];
    }
}

- (void)removeNotificationCenterObserver
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)dealloc
{
    [self performSelectorOnMainThread:@selector(removeNotificationCenterObserver) withObject:self waitUntilDone:YES];
}

#pragma mark Locked functions
- (FACachedItem *)cachedItemForKey:(id)key
{
    [self.lock lock];
    
    FACachedItem *item = [self.cachedItems objectForKey:key];
    
    [self.lock unlock];
    return item;
}

- (void)removeCachedItemForKey:(id)key
{
    [self.lock lock];
    
    [self removeExpirationDataForKey:key];
    [self.cachedItems removeObjectForKey:key];
    
    [self.lock unlock];
}

- (void)removeAllObjects
{
    [self.lock lock];
    
    [self.cachedItems removeAllObjects];
    
    [self.lock unlock];
}

- (NSUInteger)cachedItemCount
{
    [self.lock lock];
    
    NSUInteger count = self.cachedItems.count;
    
    [self.lock unlock];
    return count;
}

- (void)evictAllExpiredObjects
{
    [self.lock lock];
    
    for (id key in self.cachedItems)
    {
        [self checkExpirationDateForKey:key];
    }
    
    [self.lock unlock];
}

- (void)setCachedItem:(FACachedItem *)cachedItem forKey:(id)key
{
    [self.lock lock];
    
    [self.cachedItems setObject:cachedItem forKey:key];
    [self evictItemsIfNeeded];
    
    [self.lock unlock];
}

- (id)objectForKey:(id)key
{
    [self.lock lock];
    
    [self checkExpirationDateForKey:key];
    FACachedItem *item = [self cachedItemForKey:key];
    
    [self.lock unlock];
    return item.object;
}

- (NSArray *)cachedItemsSortedByAge
{
    [self.lock lock];
    
    NSArray *objects = self.allCachedItems;
    NSArray *sorted = [objects sortedArrayUsingComparator:^NSComparisonResult(FACachedItem *obj1, FACachedItem *obj2) {
        NSDate *firstDate = obj1.dateAdded;
        NSDate *secondDate = obj2.dateAdded;
        
        // We want to sort backwards (biggest item first)
        return [secondDate compare:firstDate];
    }];
    
    [self.lock unlock];
    
    return sorted;
}

- (NSArray *)allCachedItems
{
    [self.lock lock];
    
    NSArray *items = self.cachedItems.allValues;
    
    [self.lock unlock];
    
    return items;
}

- (NSArray *)allObjects
{
    [self.lock lock];
    
    NSArray *allKeys = self.allKeys;
    NSMutableArray *allObjects = [[NSMutableArray alloc] initWithCapacity:allKeys.count];
    for (id key in allKeys) {
        id object = [self objectForKey:key];
        
        if (object) {
            [allObjects addObject:object];
        }
    }
    
    allObjects = [allObjects copy];
    
    [self.lock unlock];
    
    return allObjects;
}

- (void)reloadAllTimers
{
    [self.lock lock];
    
    [self removeAllTimers];
    
    NSDictionary *items = self.cachedItems;
    for (id key in items) {
        FACachedItem *item = [self.cachedItems objectForKey:key];
        
        if ([item objectHasExpired])
        {
            [self removeObjectForKey:key];
        } else {
            [item setTimer];
        }
    }
    
    [self.lock unlock];
}

@end