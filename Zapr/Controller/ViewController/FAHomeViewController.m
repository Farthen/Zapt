//
//  FAHomeViewController.m
//  Zapr
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAHomeViewController.h"
#import "FANextUpViewController.h"

#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"

#import "FAContentTableViewCell.h"

#import "FATrakt.h"

@interface FAHomeViewController ()
@property FAWeightedTableViewDataSource *arrayDataSource;
@property FAArrayTableViewDelegate *arrayDelegate;

@property BOOL tableViewContainsCurrentlyWatching;

@property FATraktContent *currentlyWatchingContent;
@end

@implementation FAHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrayDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
    self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
    
    self.arrayDataSource.cellClass = [FAContentTableViewCell class];
    
    [self loadTableViewData];
    
    self.tableView.dataSource = self.arrayDataSource;
    self.tableView.delegate = self.arrayDelegate;
    
    [self loadCurrentlyWatching];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTableViewData
{
    __weak typeof(self) weakSelf = self;
    
    self.arrayDataSource.configurationBlock = ^(id cell, id object) {
        if ([object isEqual:@"currentlyWatchingRow"]) {
            FATraktContent *content = weakSelf.currentlyWatchingContent;
            
            FAContentTableViewCell *contentCell = cell;
            [contentCell displayContent:content];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    };
}

- (void)loadCurrentlyWatching
{
    [[FATrakt sharedInstance] currentlyWatchingContentCallback:^(FATraktContent *content) {
        if (content) {
            self.currentlyWatchingContent = content;
            
            if (!self.tableViewContainsCurrentlyWatching) {
                self.tableViewContainsCurrentlyWatching = YES;
                
                [self.arrayDataSource createSectionForKey:@"currentlyWatching" withWeight:0 andHeaderTitle:NSLocalizedString(@"Currently Watching", nil)];
                [self.arrayDataSource insertRow:@"currentlyWatchingRow" inSection:@"currentlyWatching" withWeight:0];
                [self.arrayDataSource recalculateWeight];
            }
        }
    } onError:nil];
}

@end
