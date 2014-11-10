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
#import "FATrakt.h"

#import "FAEpisodeAirDateTableViewCell.h"
#import "FAContentTableViewCell.h"

#import "FAInterfaceStringProvider.h"
#import "FADetailViewController.h"
#import <NSDate-Extensions/NSDate-Utilities.h>

@interface FACalendarTableViewController () <FAArrayTableViewDelegate>
@property (nonatomic) FAWeightedTableViewDataSource *dataSource;
@property (nonatomic) FAArrayTableViewDelegate *tableViewDelegate;

@property (nonatomic) NSIndexPath *scrollIndexPath;
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
    
    self.navigationItem.title = NSLocalizedString(@"Calendar", nil);
    
    self.dataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
    self.tableViewDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.dataSource];
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setupTableView
{
    self.dataSource.cellClass = [FAContentTableViewCell class];
    self.dataSource.reuseIdentifierBlock = ^NSString *(id sectionKey, id key) {
        return @"contentCell";
    };
    
    self.dataSource.weightedConfigurationBlock = ^(FAContentTableViewCell *cell, id sectionKey, id key) {
        FATraktEpisode *episode = [FATraktEpisode objectWithCacheKey:key];
        cell.calendarMode = YES;
        cell.twoLineMode = YES;
        cell.shouldDisplayImage = YES;
        [cell displayContent:episode];
        
        [episode posterImageWithWidth:42 callback:^(UIImage *image) {
            cell.image = image;
        }];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    };
    
    self.tableViewDelegate.delegate = self;
    self.tableView.rowHeight = [FAContentTableViewCell cellHeight];
    self.tableViewDelegate.forwardDelegate = self;
}

- (void)loadData
{
    [self reloadData:NO];
}

- (void)reloadData:(BOOL)animated
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:- FATimeIntervalDays(3)];
    
    [[FATrakt sharedInstance] calendarFromDate:date dayCount:7 callback:^(FATraktCalendar *calendar) {
        __block FATraktEpisode *nextEpisode = nil;
        
        NSSet *oldDates = self.dataSource.sectionKeys;
        
        for (NSDate *oldDate in oldDates) {
            if (![calendar.calendarItems containsObject:oldDate]) {
                [self.dataSource removeSectionForKey:oldDate];
            }
        }
        
        [calendar.calendarItems enumerateObjectsUsingBlock:^(FATraktCalendarItem *calendarItem, NSUInteger idx, BOOL *stop) {
            NSDate *day = calendarItem.date;
            
            NSString *title = [FAInterfaceStringProvider relativeDateFromNowWithDate:day];
            
            if (calendarItem.episodes.count >= 1) {
                FATraktEpisode *firstEpisodeOnDay = calendarItem.episodes[0];
                if (!nextEpisode && ([day isToday] || [day isLaterThanDate:[NSDate date]])) {
                    nextEpisode = firstEpisodeOnDay;
                }
                
                [self.dataSource createSectionForKey:day withWeight:idx headerTitle:title];
                
                [calendarItem.episodes enumerateObjectsUsingBlock:^(FATraktEpisode *episode, NSUInteger idx, BOOL *stop) {
                    [self.dataSource insertRow:episode.cacheKey inSection:day withWeight:idx];
                    
                    [[FATrakt sharedInstance] loadImageFromURL:episode.posterImageURL withWidth:42 callback:^(UIImage *image) {
                        FAContentTableViewCell *cell = [self.dataSource cellForRowWithKey:episode.cacheKey];
                        if (cell) {
                            cell.image = image;
                        }
                    } onError:nil];
                }];
            }
        }];
        
        [self.dataSource recalculateWeight];
        self.scrollIndexPath = [[self.dataSource indexPathsForRowKey:nextEpisode.cacheKey] anyObject];
    } onError:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowWithKey:(id)rowKey
{
    FATraktContent *content = [FATraktContent objectWithCacheKey:rowKey];
    if (content) {
        FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [detailVC loadContent:content];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.tableViewDelegate = [coder decodeObjectForKey:@"tableViewDelegate"];
    self.tableViewDelegate.tableView = self.tableView;
    self.tableViewDelegate.delegate = self;
    self.dataSource = (FAWeightedTableViewDataSource *)self.tableViewDelegate.dataSource;
    self.dataSource.tableView = self.tableView;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.tableViewDelegate;
    
    [self setupTableView];
    [self.dataSource recalculateWeight];
    [self.tableView reloadData];
    [self reloadData:NO];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.tableViewDelegate forKey:@"tableViewDelegate"];
}



@end
