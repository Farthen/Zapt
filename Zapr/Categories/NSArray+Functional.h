//
//  NSArray+Functional.h
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

// Modifies each object with the block and returns the modified array
- (NSArray *)mapUsingBlock:(id (^)(id obj, NSUInteger idx))block;

// Returns the array without the objects for which the block returned false
- (NSArray *)filterUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;

// Zip the two arrays together like a zipper
- (NSArray *)arrayZippingArray:(NSArray *)array;

// Flatten the array structure of nested arrays
- (NSArray *)flattenedArray;

// Left-Reduces the array
- (id)reduceUsingBlock:(id (^)(id memo, id object, NSUInteger idx, BOOL *stop))block;

// Returns the first object passing the test
- (id)findUsingBlock:(BOOL (^)(id obj, NSUInteger idx))block;

// Checks if every element of the array passes the test in block
- (BOOL)everyUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;

// Checks if there is an element in the array that passes the test in block
- (BOOL)someUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;

// Executes compare: with all objects in the array and returns the biggest
- (id)biggestObject;

// Executes compare: with all objects in the array and returns the smallest
- (id)smallestObject;

// Groups all objects for which the return value of the block returns zero in one NSSet
// The dictionary key is the return value of the block
- (NSDictionary *)groupByBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

// Executes valueForKey with each array element and uses this value as the dictionary key
- (NSDictionary *)indexByValueForKey:(NSString *)key;

// Returns a random object determined through arc4random_uniform
- (id)randomObject;

@end
