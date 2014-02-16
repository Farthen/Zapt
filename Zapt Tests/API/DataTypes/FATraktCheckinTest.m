//
//  FATraktCheckinTest.m
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FATraktCheckin.h"
#import "FATraktMovie.h"
#import "FATraktCheckinTimestamps.h"
#import "FATraktShow.h"

@interface FATraktCheckinTest : XCTestCase
@property NSString *dictString;
@end

@implementation FATraktCheckinTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.dictString = @"{\
    \"status\": \"success\",\
    \"message\": \"checked in to Batman Begins (2005)\",\
    \"timestamps\": {\
    \"start\": 1330670727,\
    \"end\": 1330757267,\
    \"active_for\": 8460\
    },\
    \"movie\": {\
    \"title\": \"Batman Begins\",\
    \"year\": 2005,\
    \"imdb_id\": \"tt0372784\",\
    \"tmdb_id\": 808\
    },\
    \"show\": {\
        \"title\": \"The Walking Dead\",\
        \"year\": 2010,\
        \"imdb_id\": \"tt1520211\",\
        \"tvdb_id\": 153021\
    },\
    \"facebook\": true,\
    \"twitter\": false,\
    \"tumblr\": false,\
    \"path\": false\
    }";
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testInitWithJSONDict
{
    FATraktCheckin *checkin = [[FATraktCheckin alloc] initWithJSONDict:[NSJSONSerialization JSONObjectWithData:[self.dictString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]];
    XCTAssertNotNil(checkin, @"checkin is nil");
    XCTAssertTrue([checkin isKindOfClass:[FATraktCheckin class]], @"Doesn't return FATraktCheckin");
    
    XCTAssertTrue([checkin.timestamps isKindOfClass:[FATraktCheckinTimestamps class]], @"Timestamps not the right class");
    XCTAssertTrue([checkin.timestamps.start isKindOfClass:[NSDate class]], @"Timestamp not date");
    XCTAssertTrue([checkin.timestamps.end isKindOfClass:[NSDate class]], @"Timestamp not date");
    XCTAssertEqualWithAccuracy(checkin.timestamps.active_for, 8460, 0.001, @"Not equal!");
    
    XCTAssertEqual(checkin.status, FATraktStatusSuccess);
    XCTAssertEqualObjects(checkin.message, @"checked in to Batman Begins (2005)");
}

@end
