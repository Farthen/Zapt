//
//  TMFastCache.m
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "TMFastCache.h"

@implementation TMFastCache {
    NSMutableSet *_keysToRemove;
    BOOL _shouldRemoveAllObjects;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    
    if (self) {
        _keysToRemove = [NSMutableSet set];
        
        self.memoryCache.willRemoveAllObjectsBlock = ^(TMMemoryCache *cache) {
            if (!_shouldRemoveAllObjects) {
                // Cache is evicted
                [cache enumerateObjectsWithBlock:^(TMMemoryCache *cache, NSString *key, id object) {
                    [self.diskCache setObject:object forKey:key block:nil];
                }];
            } else {
                _shouldRemoveAllObjects = NO;
            }
        };
        
        self.memoryCache.willRemoveObjectBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            if (![_keysToRemove containsObject:key]) {
                // We didn't remove this -> we need to save the value
                [self.diskCache setObject:object forKey:key block:nil];
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
    [_keysToRemove addObject:key];
    
    [super removeObjectForKey:key block:block];
}

- (void)removeAllObjects:(TMCacheBlock)block
{
    _shouldRemoveAllObjects = YES;
    
    [super removeAllObjects:block];
}

@end
