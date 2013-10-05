//
//  FATraktCachedDatatype.m
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"
#import "Misc.h"

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

- (BOOL)isEqual:(id)object
{
    if ([object respondsToSelector:@selector(cacheKey)]) {
        if ([[object cacheKey] isEqualToString:[self cacheKey]]) {
            return YES;
        }
    }
    
    return NO;
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
    if ([self.class.backingCache cachedItemForKey:self.cacheKey] == self) {
        [self.class.backingCache removeCachedItemForKey:self.cacheKey];
        self.shouldBeCached = NO;
    }
}

- (NSString *)cacheKey
{ FA_MUST_OVERRIDE_IN_SUBCLASS
    return nil;
}

+ (FACache *)backingCache
{ FA_MUST_OVERRIDE_IN_SUBCLASS
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
