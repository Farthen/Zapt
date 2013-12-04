//
//  NSSet+Functional.m
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSSet+Functional.h"

@implementation NSSet (Functional)

- (NSDictionary *)dictionaryForPairsArraysSet
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

@end
