//
//  NSArray+FunctionsTests.m
//  Zapt
//
//  Created by Finn Wilke on 16/02/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Functional.h"

@interface NSArray_FunctionsTests : XCTestCase

@end

@implementation NSArray_FunctionsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testMapUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    testArray = [testArray mapUsingBlock:^id(id obj, NSUInteger idx) {
        obj = [NSNumber numberWithInteger: [obj integerValue] * 2];
        return obj;
    }];
    
    XCTAssertEqual([testArray[0] integerValue], 2, @"Error!");
    XCTAssertEqual([testArray[1] integerValue], 4, @"Error!");
    XCTAssertEqual([testArray[2] integerValue], 6, @"Error!");
}

- (void)testFilterUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    testArray = [testArray filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj integerValue] > 2) {
            return false;
        }
        
        return true;
    }];
    
    XCTAssertEqual([testArray[0] integerValue], 1, @"Error!");
    XCTAssertEqual([testArray[1] integerValue], 2, @"Error!");
    XCTAssert([testArray count] == 2, @"Error");
}

- (void)testArrayZippingArray
{
    NSArray *testArray1 = @[@1, @2, @3];
    NSArray *testArray2 = @[@4, @5, @6];
    NSArray *zippedArray = [testArray1 arrayZippingArray:testArray2];
    
    XCTAssertEqual([zippedArray[0] integerValue], 1, @"Error!");
    XCTAssertEqual([zippedArray[1] integerValue], 4, @"Error!");
    XCTAssertEqual([zippedArray[2] integerValue], 2, @"Error!");
    XCTAssertEqual([zippedArray[3] integerValue], 5, @"Error!");
    XCTAssertEqual([zippedArray[4] integerValue], 3, @"Error!");
    XCTAssertEqual([zippedArray[5] integerValue], 6, @"Error!");
}

/*
// Flatten the array structure of nested arrays
- (NSMutableArray *)flattenedArray;

// Left-Reduces the array
- (id)reduceUsingBlock:(id (^)(id memo, id object, NSUInteger idx, BOOL *stop))block;

// Returns the count of the objects meeting the test
- (NSUInteger)countUsingBlock:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block;

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
- (NSMutableDictionary *)groupByBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

// Executes valueForKey with each array element and uses this value as the dictionary key
- (NSMutableDictionary *)indexByValueForKey:(NSString *)key;

// Returns a random object determined through arc4random_uniform
- (id)randomObject;
*/

@end
