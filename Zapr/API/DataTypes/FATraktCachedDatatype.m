//
//  FATraktCachedDatatype.m
//  Trakr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"

@implementation FATraktCachedDatatype
@synthesize shouldBeCached;

- (id)init
{
    self = [super init];
    if (self) {
        self.shouldBeCached = YES;
    }
    return self;
}

- (void)finishedMappingObjects
{
    // See if we can find a cached equivalent now and merge them if appropriate
    FATraktCachedDatatype *cachedDatatype = [self.class.backingCache objectForKey:self.cacheKey];
    if (cachedDatatype) {
        [self mergeWithObject:cachedDatatype];
        cachedDatatype.shouldBeCached = NO;
        [cachedDatatype removeFromCache];
        self.shouldBeCached = YES;
        [self commitToCache];
    }
}

- (instancetype)cachedVersion
{
    FATraktCachedDatatype *cachedVersion = [self.class.backingCache objectForKey:self.cacheKey];
    if (cachedVersion) {
        return cachedVersion;
    } else {
        [self commitToCache];
        return self;
    }
}

- (void)removeFromCache
{
    if ([self.class.backingCache objectForKey:self.cacheKey] == self) {
        [self.class.backingCache removeObjectForKey:self.cacheKey];
        self.shouldBeCached = NO;
    }
}

- (NSString *)cacheKey
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

+ (FACache *)backingCache
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)shouldMergeObjectForKey:(NSString *)key
{
    if ([key isEqualToString:@"shouldBeCached"]) {
        return NO;
    }
    return [super shouldMergeObjectForKey:key];
}

- (void)commitToCache
{
    if (self.shouldBeCached) {
        // Check if such an object is already in the cache, merge them
        FATraktCachedDatatype *cachedObject = [self.class.backingCache objectForKey:self.cacheKey];
        if (cachedObject) {
            [self mergeWithObject:cachedObject];
            cachedObject.shouldBeCached = NO;
            [cachedObject removeFromCache];
        }
        [self.class.backingCache setObject:self forKey:self.cacheKey];
    } else {
        [self removeFromCache];
    }
}

@end