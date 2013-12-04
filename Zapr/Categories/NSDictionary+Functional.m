//
//  NSDictionary+Functional.m
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSDictionary+Functional.h"

@implementation NSDictionary (Functional)

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
    
    for (id key in self)
    {
        invertedDictionary[self[key]] = key;
    }
    
    return invertedDictionary;
}

@end
