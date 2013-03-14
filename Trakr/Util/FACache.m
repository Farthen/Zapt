//
//  FACache.m
//  Trakr
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"
#import "FACachedItem.h"

@implementation FACache {
    NSMutableDictionary *_cachedItems;
    id <NSCacheDelegate> _realDelegate;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedItems = [[NSMutableDictionary alloc] init];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(removeAllTimers) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(reloadAllTimers) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [super setDelegate:self];
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
        _cachedItems = [aDecoder decodeObjectForKey:@"cachedItems"];
        for (id key in _cachedItems) {
            FACachedItem *item = [_cachedItems objectForKey:key];
            [super setObject:item forKey:key cost:item.cost];
        }
        _realDelegate = [aDecoder decodeObjectForKey:@"realDelegate"];
        self.defaultExpirationTime = [aDecoder decodeDoubleForKey:@"defaultExpirationTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cachedItems forKey:@"cachedItems"];
    [aCoder encodeObject:_realDelegate forKey:@"realDelegate"];
    [aCoder encodeDouble:self.defaultExpirationTime forKey:@"defaultExpirationTime"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACache with name: \"%@\", object count: %i, total cost:%i", self.name, self.objectCount, self.totalCost];
}

// Returns YES when the object has expired

- (void)removeExpirationDataForKey:(id)key
{
    FACachedItem *item = [_cachedItems objectForKey:key];
    [item removeExpirationData];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key
{
    FACachedItem *item = [_cachedItems objectForKey:key];
    [item setExpirationTime:expirationTime];
}

- (void)checkExpirationDateForKey:(id)key
{
    FACachedItem *item = [_cachedItems objectForKey:key];
    if ([item objectHasExpired]) {
        [self removeObjectForKey:key];
    }
}

- (void)timerElapsedForKey:(id)key
{
    [self checkExpirationDateForKey:key];
}

- (id)objectForKey:(id)key
{
    [self checkExpirationDateForKey:key];
    
    FACachedItem *item = [super objectForKey:key];
    return item.object;
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost expirationTime:(NSTimeInterval)expirationTime
{
    if (obj == nil) {
        return;
    }
    FACachedItem *item = [[FACachedItem alloc] initWithCache:self key:key object:obj];
    item.expirationTime = expirationTime;
    item.cost = cost;
    
    [super setObject:item forKey:key cost:cost];
    [_cachedItems setObject:item forKey:key];
    
    NSLog(@"Adding object %@ to cache: \"%@\", new object count: %i", [obj description], self.name, self.objectCount);
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

- (void)purgeObjectForKey:(id)key
{
    [self removeExpirationDataForKey:key];
    id obj = [_cachedItems objectForKey:key];
    [_cachedItems removeObjectForKey:key];
    
    NSLog(@"Purging object %@ from cache: \"%@\", new object count: %i", [[obj object] description], self.name, self.objectCount);
}

- (void)purgeObject:(id)obj
{
    FACachedItem *item = obj;
    id key = item.cacheKey;
    [self purgeObjectForKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [super removeObjectForKey:key];
    [self purgeObjectForKey:key];
}

- (void)removeAllObjects
{
    [super removeAllObjects];
    
    [_cachedItems removeAllObjects];
}

- (void)evictAllExpiredObjects
{
    for (id key in _cachedItems)
    {
        [self checkExpirationDateForKey:key];
    }
}

- (void)removeAllTimers
{
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        [item removeTimer];
    }
}

- (void)reloadAllTimers
{
    [self removeAllTimers];
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        if ([item objectHasExpired])
        {
            [self removeObjectForKey:key];
        } else {
            [item setTimer];
        }
    }
}

- (NSUInteger)totalCost
{
    NSUInteger totalCost = 0;
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        totalCost += item.cost;
    }
    return totalCost;
}

- (NSArray *)contentKeys
{
    return _cachedItems.allKeys;
}

- (NSUInteger)objectCount
{
    return _cachedItems.count;
}

- (id<NSCacheDelegate>)delegate
{
    return _realDelegate;
}

- (void)setDelegate:(id<NSCacheDelegate>)d
{
    _realDelegate = d;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    [_realDelegate cache:cache willEvictObject:obj];
    [self purgeObject:obj];
}

@end
