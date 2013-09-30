//
//  FACache.m
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_ERROR

@implementation FACache

- (id)init
{
    self = [super init];
    if (self) {
        _cachedItems = [[NSMutableDictionary alloc] init];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(removeAllTimers) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(reloadAllTimers) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [super setDelegate:self];
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"FACacheLock";
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
        NSMutableDictionary *cachedItems = [aDecoder decodeObjectForKey:@"cachedItems"];
        for (id key in cachedItems) {
            FACachedItem *item = [cachedItems objectForKey:key];
            [super setObject:item forKey:key cost:item.cost];
        }
        _cachedItems = cachedItems;
        _realDelegate = [aDecoder decodeObjectForKey:@"realDelegate"];
        self.defaultExpirationTime = [aDecoder decodeDoubleForKey:@"defaultExpirationTime"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
        DDLogModel(@"FACache \"%@\" loaded from coder. Keys: %@", self.name, self.allKeys);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.lock lock];
    
    [aCoder encodeObject:_cachedItems forKey:@"cachedItems"];
    [aCoder encodeObject:_realDelegate forKey:@"realDelegate"];
    [aCoder encodeDouble:self.defaultExpirationTime forKey:@"defaultExpirationTime"];
    [aCoder encodeObject:self.name forKey:@"name"];
    
    [self.lock unlock];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACache with name: \"%@\", object count: %i, total cost:%i>", self.name, self.objectCount, self.totalCost];
}

// Returns YES when the object has expired

- (void)removeExpirationDataForKey:(id)key
{
    [self.lock lock];
    FACachedItem *item = [_cachedItems objectForKey:key];
    [item removeExpirationData];
    [self.lock unlock];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key
{
    [self.lock lock];
    FACachedItem *item = [_cachedItems objectForKey:key];
    [item setExpirationTime:expirationTime];
    [self.lock unlock];
}

- (void)checkExpirationDateForKey:(id)key
{
    [self.lock lock];
    FACachedItem *item = [_cachedItems objectForKey:key];
    if ([item objectHasExpired]) {
        [self removeObjectForKey:key];
    }
    [self.lock unlock];
}

- (void)timerElapsedForKey:(id)key
{
    [self.lock lock];
    [self checkExpirationDateForKey:key];
    [self.lock unlock];
}

- (id)objectForKey:(id)key
{
    [self.lock lock];
    [self checkExpirationDateForKey:key];
    
    FACachedItem *item = [super objectForKey:key];
    [self.lock unlock];
    return item.object;
}

- (void)backingCacheSetObject:(id)obj forKey:(id)key cost:(NSUInteger)cost
{
    [self.lock lock];
    [super setObject:obj forKey:key cost:cost];
    [self.lock unlock];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost expirationTime:(NSTimeInterval)expirationTime
{
    if (obj == nil) {
        return;
    }
    
    FACachedItem *item = [[FACachedItem alloc] initWithCache:self key:key object:obj];
    item.expirationTime = expirationTime;
    item.cost = cost;
    
    [self.lock lock];
    [self backingCacheSetObject:item forKey:key cost:cost];
    [_cachedItems setObject:item forKey:key];
    [self.lock unlock];
    
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

- (void)purgeObjectForKey:(id)key
{
    [self.lock lock];
    FACachedItem *obj = [_cachedItems objectForKey:key];
    [self removeExpirationDataForKey:key];
    [_cachedItems removeObjectForKey:key];
    [self.lock unlock];
    
    DDLogModel(@"Purging object %@ for key: %@ from cache: \"%@\", new object count: %i", [[obj object] description], key, self.name, self.objectCount);
}

- (void)purgeObject:(id)obj
{
    FACachedItem *item = obj;
    id key = item.cacheKey;
    [self purgeObjectForKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.lock lock];
    [super removeObjectForKey:key];
    [self purgeObjectForKey:key];
    [self.lock unlock];
}

- (void)removeAllObjects
{
    [self.lock lock];
    [super removeAllObjects];
    
    [_cachedItems removeAllObjects];
    [self.lock unlock];
}

- (void)evictAllExpiredObjects
{
    [self.lock lock];
    for (id key in _cachedItems)
    {
        [self checkExpirationDateForKey:key];
    }
    [self.lock unlock];
}

- (void)removeAllTimers
{
    [self.lock lock];
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        [item removeTimer];
    }
    [self.lock unlock];
}

- (void)reloadAllTimers
{
    [self removeAllTimers];
    
    [self.lock lock];
    NSDictionary *items = [_cachedItems copy];
    for (id key in items) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        if ([item objectHasExpired])
        {
            [self removeObjectForKey:key];
        } else {
            [item setTimer];
        }
    }
    [self.lock unlock];
}

- (NSArray *)indexes
{
    [self.lock lock];
    NSArray *indexes = _cachedItems.allKeys;
    [self.lock unlock];
    
    return indexes;
}

- (NSUInteger)totalCost
{
    NSUInteger totalCost = 0;
    
    [self.lock lock];
    
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        totalCost += item.cost;
    }
    
    [self.lock unlock];
    
    return totalCost;
}

- (NSArray *)allKeys
{
    [self.lock lock];
    NSArray *allKeys = _cachedItems.allKeys;
    [self.lock unlock];
    
    return allKeys;
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

- (NSUInteger)objectCount
{
    [self.lock lock];
    NSUInteger count = _cachedItems.count;
    [self.lock unlock];
    
    return count;
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
    
    [self.lock lock];
    
    for (id key in _cachedItems) {
        FACachedItem *item = [_cachedItems objectForKey:key];
        if (!oldest) {
            oldest = item;
        }
        if ([item.dateAdded timeIntervalSinceDate:oldest.dateAdded] < 0) {
            oldest = item;
        }
    }
    
    [self.lock unlock];
    
    DDLogModel(@"Oldest item in cache:%@, date:%@", oldest, oldest.dateAdded);
    return oldest.object;
}

- (void)dealloc
{
    [self.lock lock];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    NSRecursiveLock *lock = self.lock;
    self.lock = nil;
    
    [lock unlock];
}

@end

@implementation FACachedItem

- (id)initWithCache:(FACache *)cache key:(id)key object:(id)object
{
    self = [super init];
    if (self) {
        _dateAdded = [NSDate date];
        _cache = cache;
        _key = key;
        _object = object;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"FACachedItem";
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
    [self.lock lock];
    
    [aCoder encodeObject:_cache forKey:@"cache"];
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeInteger:(NSInteger)self.cost forKey:@"cost"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
    [aCoder encodeDouble:_expirationTime forKey:@"expirationTime"];
    [aCoder encodeObject:_dateAdded forKey:@"dateAdded"];
    
    [self.lock unlock];
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
