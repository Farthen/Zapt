//
//  FACache+Private.h
//  Zapr
//
//  Created by Finn Wilke on 04.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"
@class FACachedItem;

@interface FACache (Private)
- (id)cachedItemForKey:(id)key;
- (void)removeCachedItemForKey:(id)key;
- (void)removeAllObjects;
- (void)evictAllExpiredObjects;
- (void)setCachedItem:(id)cachedItem forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)reloadAllTimers;
@end

@interface FACachedItem : NSObject <NSCoding>

@property (weak) FACache *cache;
@property id cacheKey;
@property id object;
@property NSDate *expirationDate;
@property NSTimer *expirationTimer;
@property NSTimeInterval expirationTime;

@property NSRecursiveLock *lock;

- (id)initWithCache:(FACache *)cache key:(id)key object:(id)object;

// The date when the item was added to the cache
@property (readonly) NSDate *dateAdded;

@property (assign) NSUInteger cost;

- (void)setTimer;
- (void)removeTimer;
- (void)removeExpirationData;
- (BOOL)objectHasExpired;

@end