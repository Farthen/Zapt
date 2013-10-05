//
//  FACache+Private.m
//  Zapr
//
//  Created by Finn Wilke on 04.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache+Private.h"

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
        self.cache = [aDecoder decodeObjectForKey:@"cache"];
        self.cacheKey = [aDecoder decodeObjectForKey:@"key"];
        self.cost = [aDecoder decodeIntegerForKey:@"cost"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
        self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
        self.expirationTime = [aDecoder decodeDoubleForKey:@"expirationTime"];
        self.dateAdded = [aDecoder decodeObjectForKey:@"dateAdded"];
        if (![self objectHasExpired]) {
            [self setTimer];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.lock lock];
    
    [aCoder encodeObject:self.cache forKey:@"cache"];
    [aCoder encodeObject:self.cacheKey forKey:@"key"];
    [aCoder encodeInteger:(NSInteger)self.cost forKey:@"cost"];
    [aCoder encodeObject:self.object forKey:@"object"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [aCoder encodeDouble:self.expirationTime forKey:@"expirationTime"];
    [aCoder encodeObject:self.dateAdded forKey:@"dateAdded"];
    
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
