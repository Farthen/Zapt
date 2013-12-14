//
//  NSSet+Functional.h
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Functional)

// Returns a dictionary for a set with pairs sets in the form @[key, obj]
- (NSMutableDictionary *)dictionaryForPairsArraysSet;

// Returns a set that contains the objects modified by block
- (NSMutableSet *)mapUsingBlock:(id (^)(id obj))block;

// Returns a set that contains all objects that meet the condition
- (NSMutableSet *)filterUsingBlock:(BOOL (^)(id obj, BOOL *stop))block;

@end
