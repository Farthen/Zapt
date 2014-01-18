//
//  NSSet+Functional.m
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSSet+Functional.h"

@implementation NSSet (Functional)

- (NSMutableDictionary *)dictionaryForPairsArraysSet
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            id key = obj[0];
            id value = obj[1];
            
            result[key] = value;
        }
    }
    
    return result;
}

- (NSMutableSet *)mapUsingBlock:(id (^)(id obj))block
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:self.count];
    
    for (id obj in self) {
        id newObj = block(obj);
        
        [set addObject:newObj];
    }
    
    return set;
}

- (NSMutableSet *)filterUsingBlock:(BOOL (^)(id obj, BOOL *stop))block
{
    NSMutableSet *result = [NSMutableSet set];
    
    BOOL stop = NO;
    
    for (id obj in self) {
        if (block(obj, &stop)) {
            [result addObject:obj];
        }
        
        if (stop) {
            break;
        }
    }
    
    return result;
}


@end
