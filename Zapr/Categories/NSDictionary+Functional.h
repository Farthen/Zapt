//
//  NSDictionary+Functional.h
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Functional)

// Returns all the keys of the dictionary as set
- (NSMutableSet *)allKeysSet;

// Returns all the values of the dictionary as set
- (NSMutableSet *)allValuesSet;

// Returns a set with arrays in the form @[key, value]
- (NSMutableSet *)pairsArraySet;

// Returns a dictionary with the keys and object swapped
- (NSMutableDictionary *)invertedDictionary;

@end
