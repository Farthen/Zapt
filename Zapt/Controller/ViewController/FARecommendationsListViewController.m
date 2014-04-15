//
//  FARecommendationsListViewController.m
//  Zapt
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FARecommendationsListViewController.h"
#import "FATrakt.h"
#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"
#import "FADetailViewController.h"

#import "FAContentTableViewCell.h"

@interface FARecommendationsListViewController ()
@property FAWeightedTableViewDataSource *weightedDataSource;
@property FAArrayTableViewDelegate *arrayDelegate;

@property NSArray *showData;
@property NSArray *movieData;
@end

@implementation FARecommendationsListViewController

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
    
    self.navigationItem.title = NSLocalizedString(@"Recommendations", nil);
    
    [self setupTableView];
}

- (void)preferredContentSizeChanged
{
    [self.view setNeedsLayout];
    [self.tableView reloadData];
}

- (void)setupTableView
{
    if (!self.weightedDataSource) {
        self.weightedDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
        self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.weightedDataSource];
        self.arrayDelegate.delegate = self;
    }
    
    self.weightedDataSource.cellClass = [FAContentTableViewCell class];
    self.weightedDataSource.weightedConfigurationBlock = ^(id cell, id sectionKey, id key) {
        
        FAContentTableViewCell *contentCell = cell;
        contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [contentCell displayContent:[FATraktContent objectWithCacheKey:key]];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayShows
{
    [self.weightedDataSource hideSection:@"movie-recommendations" animation:UITableViewRowAnimationRight];
    [self.weightedDataSource showSection:@"show-recommendations" animation:UITableViewRowAnimationLeft];
    [self.weightedDataSource recalculateWeight];
}

- (void)displayMovies
{
    [self.weightedDataSource hideSection:@"show-recommendations" animation:UITableViewRowAnimationLeft];
    [self.weightedDataSource showSection:@"movie-recommendations" animation:UITableViewRowAnimationRight];
    [self.weightedDataSource recalculateWeight];
}

- (void)displaySelectedSection
{
    if (self.searchBar.selectedScopeButtonIndex == 0) {
        [self displayShows];
    } else {
        [self displayMovies];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.weightedDataSource filterRowsUsingBlock:^BOOL(id key, BOOL *stop) {
        FATraktContent *content = [FATraktContent objectWithCacheKey:key];
        
        if (!searchText || [searchText isEqualToString:@""]) {
            return YES;
        }
        
        if ([content.title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
        
        return NO;
    }];
    
    [self.weightedDataSource recalculateWeight];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self displaySelectedSection];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    searchBar.text = nil;
    [self.weightedDataSource clearFilters];
    [self.weightedDataSource recalculateWeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowWithObject:(id)object
{
    FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [detailVC loadContent:[FATraktContent objectWithCacheKey:object]];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)loadRecommendations
{
    [self dispatchAfterViewDidLoad:^{
        [[FATrakt sharedInstance] recommendationsForContentType:FATraktContentTypeShows genre:nil startYear:0 endYear:0 hideCollected:YES hideWatchlisted:YES callback:^(NSArray *recommendations) {
            
            self.showData = recommendations;
            
            [self performBlock:^{
                [self.weightedDataSource createSectionForKey:@"show-recommendations" withWeight:0 hidden:NO];
                
                for (NSUInteger i = 0; i < self.showData.count; i++) {
                    
                    FATraktContent *content = self.showData[i];
                    [self.weightedDataSource insertRow:content.cacheKey inSection:@"show-recommendations" withWeight:i];
                }
                
                [self.weightedDataSource recalculateWeight];
            } afterDelay:0];
        } onError:nil];
        
        [[FATrakt sharedInstance] recommendationsForContentType:FATraktContentTypeMovies genre:nil startYear:0 endYear:0 hideCollected:YES hideWatchlisted:YES callback:^(NSArray *recommendations) {
            
            self.movieData = recommendations;
            
            [self performBlock:^{
                [self.weightedDataSource createSectionForKey:@"movie-recommendations" withWeight:0 hidden:YES];
                
                for (NSUInteger i = 0; i < self.movieData.count; i++) {
                    
                    FATraktContent *content = self.movieData[i];
                    [self.weightedDataSource insertRow:content.cacheKey inSection:@"movie-recommendations" withWeight:i];
                }
                
                [self.weightedDataSource recalculateWeight];
            } afterDelay:0];
            
        } onError:nil];
    }];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.showData = [coder decodeObjectForKey:@"showData"];
    self.movieData = [coder decodeObjectForKey:@"movieData"];
    
    self.arrayDelegate = [coder decodeObjectForKey:@"arrayDelegate"];
    self.weightedDataSource = (FAWeightedTableViewDataSource *)self.arrayDelegate.dataSource;
    
    self.arrayDelegate.tableView = self.tableView;
    
    self.searchBar.selectedScopeButtonIndex = [coder decodeIntegerForKey:@"selectedScopeButtonIndex"];
    
    [self setupTableView];
    
    //[self loadRecommendations];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.showData forKey:@"showData"];
    [coder encodeObject:self.movieData forKey:@"movieData"];
    
    [coder encodeObject:self.arrayDelegate forKey:@"arrayDelegate"];
    [coder encodeInteger:self.searchBar.selectedScopeButtonIndex forKey:@"selectedScopeButtonIndex"];
}

@end
