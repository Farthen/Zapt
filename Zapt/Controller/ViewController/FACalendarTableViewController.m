//
//  FACalendarTableViewController.m
//  Zapt
//
//  Created by Finn Wilke on 18/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FACalendarTableViewController.h"
#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"
#import "FAContentTableViewCell.h"
#import "FAInterfaceStringProvider.h"

@interface FACalendarTableViewController ()
@property (nonatomic) FAWeightedTableViewDataSource *dataSource;
@property (nonatomic) FAArrayTableViewDelegate *tableViewDelegate;
@end

@implementation FACalendarTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.cellClass = [FAContentTableViewCell class];
    self.dataSource.weightedConfigurationBlock = ^(FAContentTableViewCell *cell, id sectionKey, id key) {
        FATraktEpisode *episode = [FATraktEpisode objectWithCacheKey:key];
        [cell displayContent:episode];
    };
    
    self.tableViewDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.dataSource];
    
    [self.tableView reloadData];
}

- (void)loadData
{
    [self reloadData:NO];
}

- (void)reloadData:(BOOL)animated
{
    NSDate *date = [NSDate date];
    
    [[FATrakt sharedInstance] calendarFromDate:date dayCount:7 callback:^(FATraktCalendar *calendar) {
        [calendar.calendarItems enumerateObjectsUsingBlock:^(FATraktCalendarItem *calendarItem, NSUInteger idx, BOOL *stop) {
            NSDate *day = calendarItem.date;
            NSString *title = [FAInterfaceStringProvider relativeDateFromNowWithDate:day];
            
            [self.dataSource createSectionForKey:title withWeight:idx];
            
            [calendarItem.episodeCacheKeys enumerateObjectsUsingBlock:^(NSString *cacheKey, NSUInteger idx, BOOL *stop) {
                [self.dataSource insertRow:cacheKey inSection:title withWeight:idx];
            }];
            
        }];
        
        [self.dataSource recalculateWeight];
    } onError:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
