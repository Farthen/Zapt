//
//  NSSet+FunctionalTests.m
//  Zapt
//
//  Created by Finn Wilke on 16/02/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSSet+Functional.h"
#import "NSDictionary+Functional.h"

@interface NSSet_FunctionalTests : XCTestCase

@end

@implementation NSSet_FunctionalTests

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

- (void)testDictionaryForPairsArraysSet
{
    NSSet *testSet = [NSSet setWithArray:@[@[@1, @"hi"], @[@2, @"there"], @[@3, @"you"]]];
    NSDictionary *comparisonDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSDictionary *dictionary = [testSet dictionaryForPairsArraysSet];
    
    XCTAssert([dictionary isEqual:comparisonDict], @"Should be same");
    XCTAssert([[dictionary pairsArraySet] isEqual:testSet], @"Should be the same as the original again");
}

- (void)testMapUsingBlock
{
    NSSet *testSet = [NSSet setWithArray:@[@1, @2, @3]];
    
    NSSet *newSet = [testSet mapUsingBlock:^id(id obj) {
        obj = [NSNumber numberWithInteger: [obj integerValue] * 2];
        return obj;
    }];
    
    XCTAssert(newSet.count == 3, @"Should contain 3 objects");
    XCTAssert([newSet containsObject:[NSNumber numberWithInteger:2]], @"Error!");
    XCTAssert([newSet containsObject:[NSNumber numberWithInteger:4]], @"Error!");
    XCTAssert([newSet containsObject:[NSNumber numberWithInteger:6]], @"Error!");
}

- (void)testFilterUsingBlock
{
    NSSet *testSet = [NSSet setWithArray:@[@1, @2, @3]];
    NSSet *comparisonSet = [NSSet setWithArray:@[@1]];

    NSSet *newSet = [testSet filterUsingBlock:^BOOL(id obj, BOOL *stop) {
        return [obj integerValue] < 2;
    }];
    
    XCTAssert([newSet isEqual:comparisonSet], @"Should be the same");
}

@end
