//
//  FACache.h
//  Trakr
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FACacheableItem.h"

@interface FACache : NSCache <NSCacheDelegate, NSCoding>

// This NSCache subclass implements am expiration timer. You can set an expiration time for all objects.
// After that time elapsed the object is automatically removed from the cache.
// This automatically takes care of any background activity and resets all its timers when resuming.

// It also implements NSCoding so it can be written to disk easily

- (id)initWithName:(NSString *)name;

// Set object with expiration time. When the time has elapsed the object is automatically removed from the cache
- (void)setObject:(id)obj forKey:(id)key expirationTime:(NSTimeInterval)expirationTime;
- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost expirationTime:(NSTimeInterval)expirationTime;

// The total count of all objects in the cache
@property (readonly) NSUInteger objectCount;

// The total cost of all objects in the cache
@property (readonly) NSUInteger totalCost;

// Array with all the keys of the objects in the cache
@property (readonly) NSArray *contentKeys;

// Expiration time that is automatically assumed if none is given
// Set to 0 to have no default expiration time
// Will only apply to new objects added to the cache.
// If you want to set it for old object, call setExpirationTime with an expirationTime of 0
@property (assign) NSTimeInterval defaultExpirationTime;

// Set the expiration time for the object at the specified key.
// If expirationTime is 0, the default expirationTime is used.
- (void)setExpirationTime:(NSTimeInterval)expirationTime forKey:(id)key;

// Removes any expiration information for an object so that it won't expire anymore
- (void)removeExpirationDataForKey:(id)key;

// Triggered when the timer has fired for the object with key
- (void)timerElapsedForKey:(id)key;

@end
