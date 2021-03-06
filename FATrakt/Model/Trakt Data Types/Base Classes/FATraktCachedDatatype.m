//
//  FATraktCachedDatatype.m
//  Zapt
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

+ (instancetype)objectWithCacheKey:(NSString *)cacheKey
{
    return [[self backingCache] objectForKey:cacheKey];
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
    if ([self.class.backingCache objectForKey:self.cacheKey] == self) {
        [self.class.backingCache removeObjectForKey:self.cacheKey];
        self.shouldBeCached = NO;
    }
}

- (NSUInteger)hash
{
    return self.cacheKey.hash;
}

- (NSString *)cacheKey
{
    FA_MUST_OVERRIDE_IN_SUBCLASS
    
    return nil;
}

+ (TMCache *)backingCache
{
    FA_MUST_OVERRIDE_IN_SUBCLASS
    
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
        
        if (cachedObject && cachedObject != self) {
            [self mergeWithObject:cachedObject];
            cachedObject.shouldBeCached = NO;
            [cachedObject removeFromCache];
        }
        
        [self.class.backingCache setObject:self forKey:self.cacheKey block:nil];
    } else {
        [self removeFromCache];
    }
}

- (void)copyVitalDataToNewObject:(id)newDatatype
{
    [super copyVitalDataToNewObject:newDatatype];
    [newDatatype setShouldBeCached:YES];
}

@end
