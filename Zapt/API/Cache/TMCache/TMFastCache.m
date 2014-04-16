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
        
        self.memoryCache.willRemoveAllObjectsBlock = ^(TMMemoryCache *cache) {
            if (!_shouldRemoveAllObjects) {
                // Cache is evicted
                [cache enumerateObjectsWithBlock:^(TMMemoryCache *cache, NSString *key, id object) {
                    if ([_uncommittedKeys containsObject:key]) {
                        [self.diskCache setObject:object forKey:key block:nil];
                        [_uncommittedKeys removeObject:key];
                    }
                }];
            } else {
                _shouldRemoveAllObjects = NO;
            }
        };
        
        self.memoryCache.willRemoveObjectBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            if (![_keysToRemove containsObject:key] && [_uncommittedKeys containsObject:key]) {
                // We didn't remove this -> we need to save the value
                [self.diskCache setObject:object forKey:key block:nil];
                
                [_keysToRemove removeObject:key];
                [_uncommittedKeys removeObject:key];
            }
        };
    }
    
    return self;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !object)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
    }
    
    [_uncommittedKeys addObject:key];
    [self.memoryCache setObject:object forKey:key block:memBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, self.queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, object);
        });
    }
}

- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }
    
    [self.memoryCache removeObjectForKey:key block:memBlock];
    
    if ([self.diskCache.allKeys containsObject:key]) {
        [self.diskCache removeObjectForKey:key block:diskBlock];
    } else if (group) {
        dispatch_group_leave(group);
    }
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, self.queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, nil);
        });
    }
    
    
    [_keysToRemove addObject:key];
    [_uncommittedKeys removeObject:key];
}

- (void)removeAllObjects:(TMCacheBlock)block
{
    _shouldRemoveAllObjects = YES;
    
    [super removeAllObjects:block];
    [_keysToRemove removeAllObjects];
}

@end
