//
//  FACache.m
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"

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
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cachedItems forKey:@"cachedItems"];
    [aCoder encodeObject:_realDelegate forKey:@"realDelegate"];
    [aCoder encodeDouble:self.defaultExpirationTime forKey:@"defaultExpirationTime"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACache with name: \"%@\", object count: %i, total cost:%i>", self.name, self.objectCount, self.totalCost];
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
    
    //NSLog(@"Adding object %@ to cache: \"%@\", new object count: %i", [obj description], self.name, self.objectCount);
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
    [_cachedItems removeObjectForKey:key];
    
    //NSLog(@"Purging object %@ from cache: \"%@\", new object count: %i", [[obj object] description], self.name, self.objectCount);
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

- (NSArray *)indexes
{
    return _cachedItems.allKeys;
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

- (id)oldestObjectInCache
{
    FACachedItem *oldest = nil;
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        if (!oldest) {
            oldest = item;
        }
        if ([item.dateAdded timeIntervalSinceDate:oldest.dateAdded] < 0) {
            oldest = item;
        }
    }
    DDLogModel(@"Oldest item in cache:%@, date:%@", oldest, oldest.dateAdded);
    return oldest.object;
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

@end

@implementation FACachedItem {
    FACache *_cache;
    id _key;
    id _object;
    NSDate *_expirationDate;
    NSTimer *_expirationTimer;
    NSTimeInterval _expirationTime;
}

- (id)initWithCache:(FACache *)cache key:(id)key object:(id)object
{
    self = [super init];
    if (self) {
        _dateAdded = [NSDate date];
        _cache = cache;
        _key = key;
        _object = object;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        _cache = [aDecoder decodeObjectForKey:@"cache"];
        _key = [aDecoder decodeObjectForKey:@"key"];
        self.cost = [aDecoder decodeIntegerForKey:@"cost"];
        _object = [aDecoder decodeObjectForKey:@"object"];
        _expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
        _expirationTime = [aDecoder decodeDoubleForKey:@"expirationTime"];
        _dateAdded = [aDecoder decodeObjectForKey:@"dateAdded"];
        if (![self objectHasExpired]) {
            [self setTimer];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cache forKey:@"cache"];
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeInteger:self.cost forKey:@"cost"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
    [aCoder encodeDouble:_expirationTime forKey:@"expirationTime"];
    [aCoder encodeObject:_dateAdded forKey:@"dateAdded"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACachedItem with cache:%@ added on %@>", _cache, self.dateAdded];
}

- (id)cacheKey
{
    return _key;
}

- (id)object
{
    return _object;
}

- (BOOL)objectHasExpired
{
    if (_expirationDate) {
        NSTimeInterval interval = [_expirationDate timeIntervalSinceNow];
        if (interval < 0) {
            // Expiration date has passed
            return YES;
        }
    }
    return NO;
}

- (void)removeTimer
{
    [_expirationTimer invalidate];
    _expirationTimer = nil;
}

- (void)setTimer
{
    _expirationTimer = [[NSTimer alloc] initWithFireDate:_expirationDate interval:0 target:_cache selector:@selector(timerElapsedForKey:) userInfo:_key repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_expirationTimer forMode:NSDefaultRunLoopMode];
}

- (void)removeExpirationData
{
    _expirationDate = nil;
    if (_expirationTimer) {
        [_expirationTimer invalidate];
    }
    _expirationTimer = nil;
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime
{
    [self removeExpirationData];
    
    // If expiration time is set, calculate the expiration date and add a timer
    if (expirationTime > 0) {
        _expirationDate = [[NSDate date] dateByAddingTimeInterval:expirationTime];
        [self setTimer];
    }
}

- (NSTimeInterval)expirationTime
{
    return _expirationTime;
}

- (void)dealloc
{
    [_expirationTimer invalidate];
}

@end
