//
//  FACachedItem.h
//  Trakr
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FACache;

@interface FACachedItem : NSObject <NSCoding>

- (id)initWithCache:(FACache *)cache key:(id)key object:(id)object;

@property (readonly) id cacheKey;
@property (assign) NSTimeInterval expirationTime;

@property (assign) NSUInteger cost;

@property (readonly) id object;

- (void)setTimer;
- (void)removeTimer;
- (void)removeExpirationData;
- (BOOL)objectHasExpired;

@end
