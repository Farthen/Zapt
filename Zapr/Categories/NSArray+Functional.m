//
//  NSArray+Functional.m
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSMutableArray *)mapUsingBlock:(id (^)(id obj, NSUInteger idx))block
{
    if (!block) {
        return [self mutableCopy];
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    NSUInteger idx = 0;
    
    for (id obj in self) {
        id object = block(obj, idx);
        
        if (object) {
            [result addObject:object];
        }
        
        idx++;
    }
    
    return result;
}

- (NSMutableArray *)filterUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return [self mutableCopy];
    }
    
    NSMutableArray *result = [NSMutableArray array];
    NSUInteger idx = 0;
    BOOL stop = NO;
    
    for (id obj in self) {
        if (block(obj, idx, &stop)) {
            [result addObject:obj];
            
            if (stop) {
                break;
            }
        }
        
        idx++;
    }
    
    return result;
}

- (NSMutableArray *)arrayZippingArray:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count + array.count];
    
    for (NSUInteger i = 0; i < MAX(self.count, array.count); i++) {
        if (i < self.count) {
            [result addObject:array[i]];
        }
        
        if (i < array.count) {
            [result addObject:array[i]];
        }
    }
    
    return result;
}

- (NSMutableArray *)flattenedArray
{
    NSMutableArray *flattenedArray = [NSMutableArray array];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [flattenedArray addObjectsFromArray:[obj flattenedArray]];
        } else {
            [flattenedArray addObject:obj];
        }
    }
    
    return flattenedArray;
}

- (id)reduceUsingBlock:(id (^)(id memo, id object, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return nil;
    }
    
    id memo = nil;
    NSUInteger idx = 0;
    BOOL stop = NO;
    
    for (id obj in self) {
        memo = block(memo, obj, idx, &stop);
        
        if (stop) {
            break;
        }
        
        idx++;
    }
    
    return memo;
}

- (id)findUsingBlock:(BOOL (^)(id obj, NSUInteger idx))block
{
    if (!block) {
        return nil;
    }
    
    NSUInteger idx = 0;
    
    for (id obj in self) {
        if (block(obj, idx)) {
            return obj;
        }
        
        idx++;
    }
    
    return nil;
}

- (BOOL)everyUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return NO;
    }
    
    NSUInteger idx = 0;
    BOOL stop = NO;
    
    for (id obj in self) {
        if (!block(obj, idx, &stop)) {
            return NO;
        }
        
        if (stop) {
            break;
        }
        
        idx++;
    }
    
    return YES;
}

- (BOOL)someUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return NO;
    }
    
    NSUInteger idx = 0;
    BOOL stop = NO;
    
    for (id obj in self) {
        if (block(obj, idx, &stop)) {
            return YES;
        }
        
        if (stop) {
            break;
        }
        
        idx++;
    }
    
    return NO;
}

- (id)biggestObject
{
    id memo = nil;
    
    for (id obj in self) {
        if (!memo) {
            memo = obj;
        }
        
        if ([obj compare:memo] == NSOrderedDescending) {
            memo = obj;
        }
    }
    
    return memo;
}

- (id)smallestObject
{
    id memo = nil;
    
    for (id obj in self) {
        if (!memo) {
            memo = obj;
        }
        
        if ([obj compare:memo] == NSOrderedAscending) {
            memo = obj;
        }
    }
    
    return memo;
}

- (NSMutableDictionary *)groupByBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (!block) {
        return nil;
    }
    
    NSMutableDictionary *groups = [NSMutableDictionary dictionary];
    BOOL stop = NO;
    NSUInteger idx = 0;
    
    for (id obj in self) {
        id group = block(obj, idx, &stop);
        
        if (stop) {
            break;
        }
        
        NSMutableSet *groupSet = [groups objectForKey:group];
        
        if (!groupSet) {
            groupSet = [NSMutableSet set];
            [groups setObject:groupSet forKey:group];
        }
        
        [groupSet addObject:obj];
        
        idx++;
    }
    
    return groups;
}

- (NSMutableDictionary *)indexByValueForKey:(NSString *)key
{
    NSMutableDictionary *indexes = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (id obj in self) {
        id value = [obj valueForKey:key];
        [indexes setObject:obj forKey:value];
    }
    
    return indexes;
}

- (id)randomObject
{
    NSUInteger idx = arc4random_uniform(self.count);
    return self[idx];
}

@end
