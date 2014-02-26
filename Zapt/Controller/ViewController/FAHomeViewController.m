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
#import "FAShowListViewController.h"

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

@property (nonatomic) BOOL initialDataFetchDone;
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
    self.needsLoginContentName = NSLocalizedString(@"your lists", nil);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.arrayDelegate) {
        self.arrayDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
        
        self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
        self.arrayDelegate.delegate = self;
        
        self.arrayDataSource.cellClass = [FAContentTableViewCell class];
        
        self.tableView.dataSource = self.arrayDataSource;
        self.tableView.delegate = self.arrayDelegate;

        
        [self setupTableView];
        [self.tableView reloadData];
        
        [self displayUserSection];
    }
    
    __weak typeof(self) weakSelf = self;
    [self setUpRefreshControlWithActivityWithRefreshDataBlock:^(FARefreshControlWithActivity *refreshControlWithActivity) {
        [weakSelf reloadData:YES];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadData:NO];
    self.initialDataFetchDone = YES;
}

- (void)preferredContentSizeChanged
{
    [self.view setNeedsLayout];
    [self.tableView reloadData];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (content) {
                if (!self.tableViewContainsCurrentlyWatching) {
                    self.tableViewContainsCurrentlyWatching = YES;
                    
                    [self.arrayDataSource createSectionForKey:@"currentlyWatching" withWeight:0 andHeaderTitle:NSLocalizedString(@"Currently Watching", nil)];
                    [self.arrayDataSource insertRow:content inSection:@"currentlyWatching" withWeight:0];
                    [self.arrayDataSource recalculateWeight];
                }
            } else {
                if (self.tableViewContainsCurrentlyWatching) {
                    self.tableViewContainsCurrentlyWatching = NO;
                    
                    [self.arrayDataSource removeSectionForKey:@"currentlyWatching"];
                    [self.arrayDataSource recalculateWeight];
                }
            }
            
            if (animated) [self.refreshControlWithActivity finishActivity];
        });
    } onError:nil];
    
    [[FATrakt sharedInstance] watchedProgressForAllShowsCallback:^(NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showsWithProgress = result;
            [self displayProgressData];
            
            if (animated) [self.refreshControlWithActivity finishActivity];
        });
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
                // Use the content table view cell for unified experience
                cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
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
            
            FAContentTableViewCell *contentCell = cell;
            contentCell.twoLineMode = YES;
            contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if ([object isEqualToString:@"lists"]) {
                contentCell.textLabel.text = NSLocalizedString(@"Lists", nil);
                contentCell.leftAuxiliaryTextLabel.text = NSLocalizedString(@"Watchlists, Library, Custom lists", nil);
            } else if ([object isEqualToString:@"recommendations"]) {
                contentCell.textLabel.text = NSLocalizedString(@"Recommendations", nil);
                contentCell.leftAuxiliaryTextLabel.text = NSLocalizedString(@"Recommendations just for you.", nil);
            } else if ([object isEqualToString:@"shows"]) {
                contentCell.textLabel.text = NSLocalizedString(@"TV Shows", nil);
                contentCell.leftAuxiliaryTextLabel.text = NSLocalizedString(@"All your TV shows", nil);
            }
        }
    };
}

- (void)displayUserSection
{
    [self.arrayDataSource createSectionForKey:@"user" withWeight:1 andHeaderTitle:NSLocalizedString(@"Trakt User", nil)];
    [self.arrayDataSource insertRow:@"lists" inSection:@"user" withWeight:0];
    [self.arrayDataSource insertRow:@"recommendations" inSection:@"user" withWeight:1];
    [self.arrayDataSource insertRow:@"shows" inSection:@"user" withWeight:2];
    [self.arrayDataSource recalculateWeight];
}

- (void)displayProgressData
{
    if (self.showsWithProgress.count > 0) {
        if (!self.tableViewContainsProgress) {
            self.tableViewContainsProgress = YES;
            
            [self.arrayDataSource createSectionForKey:@"showProgress" withWeight:2 andHeaderTitle:NSLocalizedString(@"Recent Shows", nil)];
        }
        
        NSArray *shows = self.showsWithProgress;
        
        for (NSUInteger i = 0; i < shows.count && i < 5; i++) {
            FATraktShow *show = shows[i];
            
            [self.arrayDataSource insertRow:show inSection:@"showProgress" withWeight:i];
        }
        
    } else {
        [self.arrayDataSource removeSectionForKey:@"showProgress"];
        self.tableViewContainsProgress = NO;
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
        } else if ([object isEqualToString:@"shows"]) {
            
            FAShowListViewController *showListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showList"];
            [showListVC loadShows];
            [self.navigationController pushViewController:showListVC animated:YES];
        }
    }
}

- (void)connectionUsernameAndPasswordValidityChanged
{
    if (self.initialDataFetchDone) {
        [self reloadData:NO];
    }
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.arrayDelegate forKey:@"arrayDelegate"];
    [coder encodeBool:self.tableViewContainsCurrentlyWatching forKey:@"tableViewContainsCurrentlyWatching"];
    [coder encodeBool:self.tableViewContainsProgress forKey:@"tableViewContainsProgress"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.tableViewContainsCurrentlyWatching = [coder decodeBoolForKey:@"tableViewContainsCurrentlyWatching"];
    self.tableViewContainsProgress = [coder decodeBoolForKey:@"tableViewContainsProgress"];
    
    self.arrayDelegate = [coder decodeObjectForKey:@"arrayDelegate"];
    self.arrayDelegate.tableView = self.tableView;
    self.arrayDelegate.delegate = self;
    self.arrayDataSource = (FAWeightedTableViewDataSource *)self.arrayDelegate.dataSource;
    
    self.tableView.dataSource = self.arrayDataSource;
    self.tableView.delegate = self.arrayDelegate;
    
    [self setupTableView];
    
    [self.tableView reloadData];
}

@end
