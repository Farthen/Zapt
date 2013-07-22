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
    FATraktCachedDatatype *cachedDatatype = [self.backingCache objectForKey:self.cacheKey];
    if (cachedDatatype) {
        [self mergeWithObject:cachedDatatype];
        cachedDatatype.shouldBeCached = NO;
        [cachedDatatype removeFromCache];
        [self commitToCache];
    }
}

- (void)removeFromCache
{
    [self.backingCache removeObjectForKey:self.cacheKey];
}

- (NSString *)cacheKey
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (FACache *)backingCache
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (void)commitToCache
{
    if (self.shouldBeCached) {
        // Check if such an object is already in the cache, merge them
        if ([self.backingCache objectForKey:self.cacheKey]) {
            [self mergeWithObject:[self.backingCache objectForKey:self.cacheKey]];
        }
        [self.backingCache setObject:self forKey:self.cacheKey];
    } else {
        [self removeFromCache];
    }
}

@end
