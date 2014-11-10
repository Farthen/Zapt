//
//  NSDictionary+Functional.h
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Functional)

// Applies the block to all objects in the dictionary and returns the modified dictionary
- (NSMutableDictionary *)mapObjectsUsingBlock:(id (^)(id key, id obj))block;

// Returns a modified dictionary that contains all objects that meet the test
- (NSMutableDictionary *)filterUsingBlock:(BOOL (^)(id key, id obj, BOOL *stop))block;

// Flatten the dictionary, collapsing entries from subdictionaries. Not recursive
- (NSMutableDictionary *)flattenedDictionary;

// Returns all the keys of the dictionary as set
- (NSMutableSet *)allKeysSet;

// Returns all the values of the dictionary as set
- (NSMutableSet *)allValuesSet;

// Returns a set with arrays in the form @[key, value]
- (NSMutableSet *)pairsArraySet;

// Returns a dictionary with the keys and object swapped
- (NSMutableDictionary *)invertedDictionary;

@end
