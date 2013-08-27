//
//  FATraktDatatypeTest.m
//  Zapr
//
//  Created by Finn Wilke on 25.08.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FATraktDatatype.h"

@interface FATraktDatatypePrototype : FATraktDatatype
@property NSNull *testPropertyNull;
@property BOOL testPropertyBool;
@property NSInteger testPropertyInteger;
@property NSString *testPropertyString;
@property NSNumber *testPropertyNumber;
@property NSDate *testPropertyDate;

@property NSString *testPropertyStringUnset;
@end

@implementation FATraktDatatypePrototype
@end

@interface FATraktDatatypeTest : XCTestCase
@property NSString *testString;
@property NSNumber *testNumber;
@property NSNumber *testBool;
@property NSNumber *testInteger;

@property NSDictionary *testDictionary;
@end

@implementation FATraktDatatypeTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.testString = @"string";
    self.testBool = [NSNumber numberWithBool:YES];
    self.testNumber = [NSNumber numberWithInt:8];
    self.testInteger = [NSNumber numberWithInteger:20];
    
    self.testDictionary = @{@"testPropertyNull": [NSNull null], @"testPropertyBool": self.testBool, @"testPropertyString": self.testString, @"testPropertyNumber": self.testNumber, @"testPropertyInteger": self.testInteger};
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testInitWithJSONDict
{
    FATraktDatatype *datatype = [[FATraktDatatype alloc] initWithJSONDict:nil];
    XCTAssertNil(datatype, @"Datatype is not nil after nil dict");
    
    FATraktDatatypePrototype *datatypePrototype = [[FATraktDatatypePrototype alloc] initWithJSONDict:self.testDictionary];
    XCTAssertEqual(datatypePrototype.testPropertyNull, [NSNull null], @"datatype does not accept NSNull object");
    XCTAssertEqual(datatypePrototype.testPropertyBool, self.testBool.boolValue, @"datatype does not accept BOOL correctly");
    XCTAssertEqual(datatypePrototype.testPropertyString, self.testString, @"datatype does not accept NSStrings correctly");
    XCTAssertEqual(datatypePrototype.testPropertyNumber, self.testNumber, @"datatype does not accept NSNumber correctly");
    XCTAssertEqual(datatypePrototype.testPropertyInteger, self.testInteger.integerValue, @"datatype does not accept NSInteger correctly");
}

- (void)testMapObjectToPropertyWithKey
{
    FATraktDatatypePrototype *datatypePrototype = [[FATraktDatatypePrototype alloc] init];
    [datatypePrototype mapObject:[NSNull null] toPropertyWithKey:@"testPropertyNull"];
    XCTAssertEqual(datatypePrototype.testPropertyNull, [NSNull null], @"datatype does not accept NSNull objects");
}

- (void)testMergeWithObject
{
    FATraktDatatypePrototype *datatypePrototype = [[FATraktDatatypePrototype alloc] init];
    [datatypePrototype mapObject:self.testString toPropertyWithKey:@"testPropertyString"];
    [datatypePrototype mapObject:self.testInteger toPropertyWithKey:@"testPropertyInteger"];
    [datatypePrototype mapObject:self.testBool toPropertyWithKey:@"testPropertyBool"];
    
    FATraktDatatypePrototype *datatypePrototype2 = [[FATraktDatatypePrototype alloc] init];
    NSString *testString2 = @"testString2";
    [datatypePrototype2 mapObject:testString2 toPropertyWithKey:@"testPropertyString"];
    [datatypePrototype2 mapObject:self.testInteger toPropertyWithKey:@"testPropertyInteger"];
    [datatypePrototype2 mapObject:self.testNumber toPropertyWithKey:@"testPropertyNumber"];
    
    [datatypePrototype mergeWithObject:datatypePrototype2];
    XCTAssertEqual(datatypePrototype.testPropertyString, testString2, @"Merge doesn't overwrite properties even though it should");
    XCTAssertEqual(datatypePrototype.testPropertyInteger, self.testInteger.integerValue, @"Merge overwrites properties with random data. WTF");
    XCTAssertEqual(datatypePrototype.testPropertyBool, self.testBool.boolValue, @"Merge overwrites things that aren't even set in the target");
    XCTAssertEqual(datatypePrototype.testPropertyNumber, self.testNumber, @"Merge doesn't overwrite unset properties in the reciever");
}


/*- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}*/

@end
