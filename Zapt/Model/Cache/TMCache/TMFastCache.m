//
//  TMFastCache.m
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "TMFastCache.h"

@implementation TMFastCache {
    NSMutableSet *_uncommittedKeys;

    NSMutableSet *_keysToRemove;
    BOOL _shouldRemoveAllObjects;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];

    if (self) {
        _keysToRemove = [NSMutableSet set];
        _uncommittedKeys = [NSMutableSet set];

        self.memoryCache.willRemoveAllObjectsBlock = ^(TMMemoryCache *cache, NSDictionary *data) {
            if (!_shouldRemoveAllObjects) {
                // Cache is evicted
                
                dispatch_sync(self.queue, ^{
                    [_keysToRemove enumerateObjectsUsingBlock:^(id key, BOOL *stop) {
                        [self.diskCache removeObjectForKey:key];
                    }];
                    
                    [_keysToRemove removeAllObjects];
                    
                    for (id key in data) {
                        id object = data[key];
                        
                        if ([_uncommittedKeys containsObject:key]) {
                            [self.diskCache setObject:object forKey:key];
                            
                            [_uncommittedKeys removeObject:key];
                        }
                    }
                });
            } else {
                _shouldRemoveAllObjects = NO; // atomic
            }
        };

        self.memoryCache.willRemoveObjectBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            
            dispatch_sync(self.queue, ^{
                if (![_keysToRemove containsObject:key] && [_uncommittedKeys containsObject:key]) {
                    // We didn't remove this -> we need to save the value
                    [self.diskCache setObject:object forKey:key block:nil];
                    
                    [_keysToRemove removeObject:key];
                    [_uncommittedKeys removeObject:key];
                }
            });
        };
    }

    return self;
}

- (void)commitAllObjects
{
    dispatch_sync(self.queue, ^{
        [_keysToRemove enumerateObjectsUsingBlock:^(id key, BOOL *stop) {
            [self.diskCache removeObjectForKey:key];
        }];
        
        [_keysToRemove removeAllObjects];
        
        [self.memoryCache enumerateObjectsWithBlock:^(TMMemoryCache *cache, NSString *key, id object) {
            if ([_uncommittedKeys containsObject:key]) {
                [self.diskCache setObject:object forKey:key];
                
                [_uncommittedKeys removeObject:key];
            }
        }];
    });
}

- (void)setObject:(id <NSCoding> )object forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !object) {
        return;
    }
    
    dispatch_async(self.queue, ^{
        [_keysToRemove removeObject:key];
        [_uncommittedKeys addObject:key];
    });
    
    __weak TMCache *weakSelf = self;
    [self.memoryCache setObject:object forKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
        TMCache *strongSelf = weakSelf;
        
        if (strongSelf) {
            block(strongSelf, key, object);
        }
    }];
}

- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key) {
        return;
    }
    
    dispatch_async(self.queue, ^{
        [_keysToRemove addObject:key];
        [_uncommittedKeys removeObject:key];
    });
    
    __weak TMCache *weakSelf = self;
    [self.memoryCache removeObjectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
        TMCache *strongSelf = weakSelf;
        if (block) {
            block(strongSelf, key, object);
        }
    }];
}

- (void)removeAllObjects:(TMCacheBlock)block
{
    _shouldRemoveAllObjects = YES; // atomic

    [super removeAllObjects:block];
    
    dispatch_async(self.queue, ^{
        [_keysToRemove removeAllObjects];
    });
}

@end
