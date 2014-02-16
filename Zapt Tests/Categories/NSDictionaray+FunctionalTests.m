//
//  NSDictionaray+FunctionalTests.m
//  Zapt
//
//  Created by Finn Wilke on 16/02/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDictionary+Functional.h"

@interface NSDictionaray_FunctionalTests : XCTestCase

@end

@implementation NSDictionaray_FunctionalTests

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

- (void)testMapObjectsUsingBlock
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSDictionary *newDict = [testDict mapObjectsUsingBlock:^id(id key, id obj) {
        return [NSString stringWithFormat:@"%@: %@", key, obj];
    }];
    
    XCTAssert([newDict[@1] isEqualToString:@"1: hi"], @"Error");
    XCTAssert([newDict[@2] isEqualToString:@"2: there"], @"Error");
    XCTAssert([newDict[@3] isEqualToString:@"3: you"], @"Error");
}

- (void)testFilterUsingBlock
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSDictionary *filteredDict = [testDict filterUsingBlock:^BOOL(id key, id obj, BOOL *stop) {
        return [key integerValue] <= 2 && ![obj isEqualToString:@"there"];
    }];
    
    XCTAssert(filteredDict.count == 1, @"Should only contain one object");
    XCTAssert([filteredDict[@1] isEqualToString:@"hi"], @"that object should be @1: hi");
}

- (void)testFlattenedDictionary
{
    NSDictionary *testDict = @{@1: @{@1: @"hi", @2: @"there"}, @3: @"you"};
    NSDictionary *comparisionDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSDictionary *newDict = [testDict flattenedDictionary];
    XCTAssert([newDict isEqual:comparisionDict], @"Dicts should be the same");
}

- (void)testAllKeysSet
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSSet *allKeysSet = [testDict allKeysSet];
    
    XCTAssert([allKeysSet isEqual:[NSSet setWithArray:[testDict allKeys]]], @"Should be same");
}

- (void)testAllValuesSet
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    
    NSSet *allValuesSet = [testDict allValuesSet];
    
    XCTAssert([allValuesSet isEqual:[NSSet setWithArray:[testDict allValues]]], @"Should be same");
}

- (void)testPairsArraySet
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    NSSet *comparisonSet = [NSSet setWithArray:@[@[@1, @"hi"], @[@2, @"there"], @[@3, @"you"]]];
    
    NSSet *pairsArraySet = [testDict pairsArraySet];
    
    XCTAssert([comparisonSet isEqual:pairsArraySet], @"Should be the same");
}

- (void)testInvertedDictionaray
{
    NSDictionary *testDict = @{@1: @"hi", @2: @"there", @3: @"you"};
    NSDictionary *comparisonDict = @{@"hi": @1, @"there": @2, @"you": @3};
    
    NSDictionary *invertedDictionary = [testDict invertedDictionary];
    XCTAssert([invertedDictionary isEqual:comparisonDict], @"Should be the same");
}

@end
