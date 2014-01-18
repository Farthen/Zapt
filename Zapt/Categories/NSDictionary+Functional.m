//
//  NSDictionary+Functional.m
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSDictionary+Functional.h"

@implementation NSDictionary (Functional)

- (NSMutableDictionary *)mapObjectsUsingBlock:(id (^)(id key, id obj))block
{
    if (!block) {
        return [self mutableCopy];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (id key in self) {
        id obj = self[key];
        
        obj = block(key, obj);
        
        [result setObject:obj forKey:key];
    }
    
    return result;
}

- (NSMutableDictionary *)filterUsingBlock:(BOOL (^)(id key, id obj, BOOL *stop))block
{
    if (!block) {
        return [self mutableCopy];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    BOOL stop = NO;
    
    for (id key in self) {
        id obj = self[key];
        
        if (block(key, obj, &stop)) {
            [result setObject:obj forKey:key];
        }
        
        if (stop) {
            break;
        }
    }
    
    return result;
}

- (NSMutableDictionary *)flattenedDictionary
{
    NSMutableDictionary *flattenedDictionary = [NSMutableDictionary dictionary];
    
    for (id key in self) {
        id obj = self[key];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [flattenedDictionary addEntriesFromDictionary:obj];
        } else {
            [flattenedDictionary setObject:obj forKey:key];
        }
    }
    
    return flattenedDictionary;
}

- (NSMutableSet *)allKeysSet
{
    NSMutableSet *keySet = [NSMutableSet setWithCapacity:self.count];
    
    for (id key in self) {
        [keySet addObject:key];
    }
    
    return keySet;
}

- (NSMutableSet *)allValuesSet
{
    NSMutableSet *valueSet = [NSMutableSet setWithCapacity:self.count];
    
    for (id key in self) {
        [valueSet addObject:self[key]];
    }
    
    return valueSet;
}

- (NSMutableSet *)pairsArraySet
{
    NSMutableSet *pairsSet = [NSMutableSet setWithCapacity:self.count];
    
    for (id key in self) {
        [pairsSet addObject:@[key, self[key]]];
    }
    
    return pairsSet;
}

- (NSMutableDictionary *)invertedDictionary
{
    NSMutableDictionary *invertedDictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (id key in self) {
        invertedDictionary[self[key]] = key;
    }
    
    return invertedDictionary;
}

@end
