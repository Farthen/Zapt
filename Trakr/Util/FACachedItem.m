//
//  FACachedItem.m
//  Trakr
//
//  Created by Finn Wilke on 13.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACachedItem.h"
#import "FACache.h"

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
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FACachedItem with cache:%@>", _cache];
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
