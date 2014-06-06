//
//  FAWeightedTableViewDataSourceTest.m
//  Zapt
//
//  Created by Finn Wilke on 07/06/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FAWeightedTableViewDataSource.h"

@interface FAWeightedTableViewDataSourceTest : XCTestCase
@property (nonatomic) FAWeightedTableViewDataSource *weightedDataSource;
@property (nonatomic) UIWindow *window;
@end

@implementation FAWeightedTableViewDataSourceTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    self.window.rootViewController = tableViewController;
    self.weightedDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:tableViewController.tableView];
    
    [self.window makeKeyAndVisible];
    
    self.weightedDataSource.weightedConfigurationBlock = ^(UITableViewCell *cell, id sectionKey, id key) {
        cell.textLabel.text = key;
    };
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)clearWeightedDispatchQueue
{
    NSDate *startDate = [NSDate date];
    long timeout;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async([FAWeightedTableViewDataSource weightedDispatchQueue], ^{
        dispatch_semaphore_signal(semaphore);
    });
    
    do {
        timeout = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
        [[NSRunLoop currentRunLoop]
         runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        
        if ([startDate timeIntervalSinceNow] < -10) {
            XCTFail(@"Took too long to wait for async queue");
            break;
        }
    } while (timeout != 0);
}

- (void)testRecalculateWeight
{
    [self.weightedDataSource createSectionForKey:@"testSection" withWeight:0];
    [self.weightedDataSource createSectionForKey:@"testSection2" withWeight:1];
    [self.weightedDataSource insertRow:@"row1" inSection:@"testSection" withWeight:0];
    [self.weightedDataSource recalculateWeight];
    [self clearWeightedDispatchQueue];
    
    [self.weightedDataSource removeSectionForKey:@"testSection"];
    [self.weightedDataSource recalculateWeight];
    
    [self.weightedDataSource removeSectionForKey:@"testSection2"];
    [self.weightedDataSource insertRow:@"row2" inSection:@"testSection2" withWeight:2];
    [self.weightedDataSource recalculateWeight];
    [self clearWeightedDispatchQueue];
    
    [self.weightedDataSource createSectionForKey:@"testSection" withWeight:0];
    [self.weightedDataSource insertRow:@"row1" inSection:@"testSection" withWeight:2];
    [self.weightedDataSource removeRowWithKey:@"row1"];
    [self.weightedDataSource recalculateWeight];
    [self clearWeightedDispatchQueue];
}

- (void)testCoding
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.weightedDataSource];
    self.weightedDataSource = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [self.weightedDataSource removeSectionForKey:@"testSection"];
    [self.weightedDataSource recalculateWeight];
    [self clearWeightedDispatchQueue];
    
    [self.weightedDataSource removeAllSections];
    [self.weightedDataSource recalculateWeight];
    [self clearWeightedDispatchQueue];
}

@end
