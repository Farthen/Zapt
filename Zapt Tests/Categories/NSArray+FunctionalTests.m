//
//  NSArray+FunctionsTests.m
//  Zapt
//
//  Created by Finn Wilke on 16/02/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Functional.h"

@interface NSArray_FunctionalTests : XCTestCase

@end

@implementation NSArray_FunctionalTests

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

- (void)testFlattenedArray
{
    NSArray *testArray = @[@[@1, @[@2]], @3];
    NSArray *flattenedArray = [testArray flattenedArray];
    
    XCTAssertEqual([flattenedArray[0] integerValue], 1, @"Error!");
    XCTAssertEqual([flattenedArray[1] integerValue], 2, @"Error!");
    XCTAssertEqual([flattenedArray[2] integerValue], 3, @"Error!");
}

- (void)testReduceUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    
    NSNumber *reducedNumber = [testArray reduceUsingBlock:^id(id memo, id object, NSUInteger idx, BOOL *stop) {
        if (!memo) {
            memo = object;
        } else {
            memo = [NSNumber numberWithInteger:[memo integerValue] + [object integerValue]];
        }
        
        return memo;
    }];
    
    XCTAssert([reducedNumber integerValue] == 6, @"Error");
}

- (void)testCountUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    
    NSUInteger count = [testArray countUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj integerValue] < 2;
    }];
    
    XCTAssert(count == 1, @"Error");
}

- (void)testFindUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    
    NSNumber *obj = [testArray findUsingBlock:^BOOL(id obj, NSUInteger idx) {
        return [obj integerValue] == 2;
    }];
    
    XCTAssert([obj integerValue] == 2, @"Error");
}

- (void)testEveryUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    
    BOOL result = [testArray everyUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj integerValue] > 1;
    }];
    
    XCTAssert(!result, @"Condition wasn't met by all objects!");
    
    result = [testArray everyUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj integerValue] < 10;
    }];
    
    XCTAssert(result, @"Condition was met by all objects!");
}

- (void)testSomeUsingBlock
{
    NSArray *testArray = @[@1, @2, @3];
    
    BOOL result = [testArray someUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj integerValue] >= 3;
    }];
    
    XCTAssert(result, @"3 is included and 3 >= 3");
}

- (void)testBiggestObject
{
    NSArray *testArray = @[@1, @2, @3];
    
    NSNumber *biggestObject = [testArray biggestObject];
    
    XCTAssert([biggestObject integerValue] == 3, @"Biggest Object should be 3");
}

- (void)testSmallestObject
{
    NSArray *testArray = @[@1, @2, @3];
    
    NSNumber *smallestObject = [testArray smallestObject];
    
    XCTAssert([smallestObject integerValue] == 1, @"Smallest Object should be 1");
}

- (void)testGroupByBlock
{
    NSArray *testArray = @[@1, @2, @3, @4, @5];
    
    NSDictionary *groupedDict = [testArray groupByBlock:^id(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj integerValue] < 3) {
            return @1;
        } else {
            return @2;
        }
    }];
    
    XCTAssert(groupedDict.count == 2, @"Dict should have 2 entries");
    
    NSSet *firstSet = groupedDict[@1];
    XCTAssertNotNil(firstSet, @"firstSet should be an object");
    XCTAssert([firstSet isKindOfClass:[NSSet class]], @"firstSet should be of class set");
    XCTAssert(firstSet.count == 2, @"firstSet should contain 2 objects");
    XCTAssert([firstSet containsObject:@1], @"firstSet should contain @1");
    XCTAssert([firstSet containsObject:@2], @"firstSet should contain @2");
    XCTAssert(![firstSet containsObject:@3], @"firstSet should not contain @3");
    XCTAssert(![firstSet containsObject:@4], @"firstSet should not contain @4");
    XCTAssert(![firstSet containsObject:@5], @"firstSet should not contain @5");
    
    NSSet *secondSet = groupedDict[@2];
    XCTAssertNotNil(secondSet, @"secondSet should be an object");
    XCTAssert([secondSet isKindOfClass:[NSSet class]], @"secondSet should be of class set");
    XCTAssert(secondSet.count == 3, @"secondSet should contain 3 objects");
    XCTAssert(![secondSet containsObject:@1], @"secondSet should not contain @1");
    XCTAssert(![secondSet containsObject:@2], @"secondSet should not contain @2");
    XCTAssert([secondSet containsObject:@3], @"secondSet should contain @3");
    XCTAssert([secondSet containsObject:@4], @"secondSet should contain @4");
    XCTAssert([secondSet containsObject:@5], @"secondSet should contain @5");
}

- (void)testIndexByValueForKey
{
    NSArray *testArray = @[@"Hi", @"the", @"you!", @"stuff"];
    
    NSDictionary *indexes = [testArray indexByValueForKey:@"length"];
    
    XCTAssert(indexes.count == 4, @"Should contain 4 keys");
    XCTAssert([indexes[@2] isEqualToString:@"Hi"], @"Error");
    XCTAssert([indexes[@3] isEqualToString:@"the"], @"Error");
    XCTAssert([indexes[@4] isEqualToString:@"you!"], @"Error");
    XCTAssert([indexes[@5] isEqualToString:@"stuff"], @"Error");
}

- (void)testRandomObject
{
    NSArray *testArray = @[@1, @2, @3, @4, @5];
    
    NSNumber *randomObject = [testArray randomObject];
    
    XCTAssert([testArray containsObject:randomObject], @"The random object should be included in the array");
}

@end
