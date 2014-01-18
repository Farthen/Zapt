//
//  FAHomeViewController.m
//  Zapt
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAHomeViewController.h"
#import "FANextUpViewController.h"
#import "FADetailViewController.h"
#import "FAListsViewController.h"
#import "FARecommendationsListViewController.h"

#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"

#import "FAContentTableViewCell.h"

#import "FATrakt.h"

@interface FAHomeViewController ()
@property FAWeightedTableViewDataSource *arrayDataSource;
@property FAArrayTableViewDelegate *arrayDelegate;

@property BOOL tableViewContainsCurrentlyWatching;
@property BOOL tableViewContainsProgress;

@property NSArray *showsWithProgress;
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
    self.needsLoginContentName = NSLocalizedString(@"the home view", nil);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrayDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
    
    self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
    self.arrayDelegate.delegate = self;
    
    self.arrayDataSource.cellClass = [FAContentTableViewCell class];
    
    [self setupTableView];
    
    self.tableView.dataSource = self.arrayDataSource;
    self.tableView.delegate = self.arrayDelegate;
    
    [self displayUserSection];
    
    __weak typeof(self) weakSelf = self;
    [self setUpRefreshControlWithActivityWithRefreshDataBlock:^(FARefreshControlWithActivity *refreshControlWithActivity) {
        [weakSelf reloadData:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadData:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData:(BOOL)animated
{
    if (animated) [self.refreshControlWithActivity startActivityWithCount:2];
    
    [[FATrakt sharedInstance] currentlyWatchingContentCallback:^(FATraktContent *content) {
        if (content) {
            if (!self.tableViewContainsCurrentlyWatching) {
                self.tableViewContainsCurrentlyWatching = YES;
                
                [self.arrayDataSource createSectionForKey:@"currentlyWatching" withWeight:0 andHeaderTitle:NSLocalizedString(@"Currently Watching", nil)];
                [self.arrayDataSource insertRow:content inSection:@"currentlyWatching" withWeight:0];
                [self.arrayDataSource recalculateWeight];
            }
        }
        
        if (animated) [self.refreshControlWithActivity finishActivity];
    } onError:nil];
    
    [[FATrakt sharedInstance] watchedProgressForAllShowsCallback:^(NSArray *result) {
        self.showsWithProgress = result;
        [self displayProgressData];
        
        if (animated) [self.refreshControlWithActivity finishActivity];
    } onError:nil];
}

- (void)setupTableView
{
    __weak typeof(self) weakSelf = self;
    self.arrayDataSource.weightedCellCreationBlock = ^(id sectionKey, id object) {
        id cell = nil;
        
        NSString *reuseIdentifier = nil;
        
        if ([sectionKey isEqualToString:@"user"]) {
            reuseIdentifier = @"user";
        } else {
            reuseIdentifier = @"content";
        }
        
        cell = [weakSelf.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        
        if (!cell) {
            if ([sectionKey isEqualToString:@"user"]) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            } else {
                cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
        }
        
        return cell;
    };
    
    self.arrayDataSource.weightedConfigurationBlock = ^(id cell, id sectionKey, id object) {
        if ([sectionKey isEqualToString:@"currentlyWatching"]) {
            FATraktContent *content = object;
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.twoLineMode = YES;
            [contentCell displayContent:content];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([sectionKey isEqualToString:@"showProgress"]) {
            FATraktShow *show = object;
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.showsProgressForShows = YES;
            contentCell.twoLineMode = YES;
            [contentCell displayContent:show];
            
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if ([sectionKey isEqualToString:@"user"]) {
            
            UITableViewCell *standardCell = cell;
            standardCell.detailTextLabel.textColor = [UIColor grayColor];
            standardCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if ([object isEqualToString:@"lists"]) {
                standardCell.textLabel.text = NSLocalizedString(@"Lists", nil);
                standardCell.detailTextLabel.text = NSLocalizedString(@"Watchlists, Library, Custom lists", nil);
            } else if ([object isEqualToString:@"recommendations"]) {
                standardCell.textLabel.text = NSLocalizedString(@"Recommendations", nil);
                standardCell.detailTextLabel.text = NSLocalizedString(@"Recommendations just for you.", nil);
            }
        }
    };
}

- (void)displayUserSection
{
    [self.arrayDataSource createSectionForKey:@"user" withWeight:1 andHeaderTitle:NSLocalizedString(@"Trakt User", nil)];
    [self.arrayDataSource insertRow:@"lists" inSection:@"user" withWeight:0];
    [self.arrayDataSource insertRow:@"recommendations" inSection:@"user" withWeight:1];
    [self.arrayDataSource recalculateWeight];
}

- (void)displayProgressData
{
    if (!self.tableViewContainsProgress) {
        self.tableViewContainsProgress = YES;
        
        [self.arrayDataSource createSectionForKey:@"showProgress" withWeight:2 andHeaderTitle:NSLocalizedString(@"Recent Shows", nil)];
    }
    
    NSArray *shows = self.showsWithProgress;
    
    for (NSUInteger i = 0; i < shows.count && i < 5; i++) {
        FATraktShow *show = shows[i];
        
        [self.arrayDataSource insertRow:show inSection:@"showProgress" withWeight:i];
    }
    
    [self.arrayDataSource recalculateWeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowWithObject:(id)object
{
    if ([object isKindOfClass:[FATraktContent class]]) {
        FATraktContent *content = object;
        
        FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [detailVC loadContent:content];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"lists"]) {
            
            FAListsViewController *listsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"lists"];
            [self.navigationController pushViewController:listsVC animated:YES];
            
        } else if ([object isEqualToString:@"recommendations"]) {
            
            FARecommendationsListViewController *recommendationsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"recommendations"];
            [recommendationsListVC loadRecommendations];
            [self.navigationController pushViewController:recommendationsListVC animated:YES];
        }
    }
}

@end
