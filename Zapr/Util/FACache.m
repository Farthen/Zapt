//
//  FACache.m
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"
#import "FACache+Private.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_INFO

static const NSInteger codingVersionNumber = 6;

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
        
        [notificationCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationDidReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(applicationWillTerminateNotification:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (id)initWithName:(NSString *)name loadFromDisk:(BOOL)load
{
    id instance = nil;
    
    if (load) {
        instance = [FACache cacheFromDiskWithName:name];
    }
    
    if (!instance) {
        instance = [self initWithName:name];
    }
    
    self = instance;
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
    if (codingVersionNumber == [aDecoder decodeIntegerForKey:@"codingVersionNumber"]) {
        self = [self init];
        if (self) {
            self.defaultExpirationTime = [aDecoder decodeDoubleForKey:@"defaultExpirationTime"];
            self.name = [aDecoder decodeObjectForKey:@"name"];
            
            NSMutableDictionary *cachedItems = [aDecoder decodeObjectForKey:@"cachedItems"];
            if (cachedItems) {
                self.cachedItems = cachedItems;
                for (id key in cachedItems) {
                    FACachedItem *cachedItem = [cachedItems objectForKey:key];
                    cachedItem.cache = self;
                }
            }
            
            DDLogModel(@"FACache \"%@\" loaded from coder. Keys: %@", self.name, self.allKeys);
        }
    } else {
        DDLogWarn(@"Cache version number has changed. Rebuilding cache…");
        return nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.lock lock];
    
    [aCoder encodeDouble:self.defaultExpirationTime forKey:@"defaultExpirationTime"];
    [aCoder encodeObject:self.name forKey:@"name"];
    
    [aCoder encodeObject:self.cachedItems forKey:@"cachedItems"];
    [aCoder encodeInteger:codingVersionNumber forKey:@"codingVersionNumber"];
    
    [self.lock unlock];
}

+ (BOOL)removeCacheFileWithName:(NSString *)name
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self filePathWithCacheName:name] error:nil];
}

+ (NSString *)codingFileNameWithCacheName:(NSString *)name
{
    return [NSString stringWithFormat:@"FACache-%@", name];
}

+ (NSString *)filePathWithCacheName:(NSString *)name
{
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList  objectAtIndex:0];
    
    return [myPath stringByAppendingPathComponent:[self codingFileNameWithCacheName:(NSString *)name]];
}

+ (long long)fileSizeWithCacheName:(NSString *)name
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self filePathWithCacheName:name] error:nil];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber longLongValue];
}

- (BOOL)saveToDisk
{
    [self.lock lock];
    BOOL worked = [NSKeyedArchiver archiveRootObject:self toFile:[self.class filePathWithCacheName:self.name]];
    
    DDLogInfo(@"Saving cache %@. File size: %.8fMB", [self description], ((double)[self.class fileSizeWithCacheName:self.name] / 1024 / 1024));
    
    [self.lock unlock];
    
    return worked;
}

+ (id)cacheFromDiskWithName:(NSString *)name
{
    id cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathWithCacheName:name]];
    if (!cache) {
        [self removeCacheFileWithName:name];
    }
    
    DDLogInfo(@"Loading cache %@. File size: %.8fMB", [cache description], ((double)[self fileSizeWithCacheName:name] / 1024 / 1024));
    
    return cache;
}

- (void)reloadDataFromDisk
{
    [self.lock lock];
    
    FACache *cache = [FACache cacheFromDiskWithName:self.name];
    if (cache.cachedItems) {
        self.cachedItems = cache.cachedItems;
        for (id key in self.cachedItems) {
            FACachedItem *cachedItem = [self.cachedItems objectForKey:key];
            cachedItem.cache = self;
        }
    }
    
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

- (void)evictAllObjects
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willEvictAllObjectsInCache:)]) {
        [self.delegate willEvictAllObjectsInCache:self];
    }
    
    [self removeAllObjects];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEvictAllObjectInCache:)]) {
        [self.delegate didEvictAllObjectInCache:self];
    }
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
    NSMutableArray *removeKeys = [[NSMutableArray alloc] init];
    
    for (id key in items) {
        FACachedItem *item = [self.cachedItems objectForKey:key];
        
        if ([item objectHasExpired])
        {
            [removeKeys addObject:key];
        } else {
            [item setTimer];
        }
    }
    
    [self.cachedItems removeObjectsForKeys:removeKeys];
    [self.lock unlock];
}

#pragma mark Notifications
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
}

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self reloadDataFromDisk];
    [self reloadAllTimers];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self removeAllTimers];
    [self saveToDisk];
}

- (void)applicationDidReceiveMemoryWarningNotification:(NSNotification *)notification
{
    // We *really* need to free some memory so just evict all cached objects
    [self saveToDisk];
    [self evictAllObjects];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self saveToDisk];
}

@end

@interface FACachedItem () {
    NSTimeInterval _expirationTime;
}

@property NSDate *dateAdded;
@end

@implementation FACachedItem

- (id)initWithCache:(FACache *)cache key:(id)key object:(id)object
{
    self = [super init];
    if (self) {
        self.dateAdded = [NSDate date];
        self.cache = cache;
        _cacheKey = key;
        self.object = object;
        
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
        _cacheKey = [aDecoder decodeObjectForKey:@"key"];
        _cost = [aDecoder decodeIntegerForKey:@"cost"];
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
    [aCoder encodeObject:_cacheKey forKey:@"key"];
    [aCoder encodeInteger:(NSInteger)self.cost forKey:@"cost"];
    [aCoder encodeObject:_object forKey:@"object"];
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
    [aCoder encodeDouble:_expirationTime forKey:@"expirationTime"];
    [aCoder encodeObject:_dateAdded forKey:@"dateAdded"];
    
    [self.lock unlock];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACachedItem with cache:%@ added on %@>", self.cache, self.dateAdded];
}

- (BOOL)objectHasExpired
{
    if (self.expirationDate) {
        NSTimeInterval interval = [self.expirationDate timeIntervalSinceNow];
        if (interval < 0) {
            // Expiration date has passed
            return YES;
        }
    }
    return NO;
}

- (void)removeTimer
{
    [self.expirationTimer invalidate];
    self.expirationTimer = nil;
}

- (void)setTimer
{
    self.expirationTimer = [[NSTimer alloc] initWithFireDate:self.expirationDate interval:0 target:self.cache selector:@selector(timerElapsedForKey:) userInfo:self.cacheKey repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.expirationTimer forMode:NSDefaultRunLoopMode];
}

- (void)removeExpirationData
{
    self.expirationDate = nil;
    [self removeTimer];
}

- (void)setExpirationTime:(NSTimeInterval)expirationTime
{
    [self removeExpirationData];
    
    // If expiration time is set, calculate the expiration date and add a timer
    if (expirationTime > 0) {
        self.expirationDate = [[NSDate date] dateByAddingTimeInterval:expirationTime];
        [self setTimer];
    }
}

- (NSTimeInterval)expirationTime
{
    return _expirationTime;
}

- (void)dealloc
{
    [self.expirationTimer invalidate];
}

@end