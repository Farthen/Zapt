//
//  FARecommendationsListViewController.m
//  Zapr
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
    
    self.weightedDataSource = [[FAWeightedTableViewDataSource alloc] initWithTableView:self.tableView];
    self.arrayDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.weightedDataSource];
    self.arrayDelegate.delegate = self;
    
    self.weightedDataSource.cellClass = [FAContentTableViewCell class];
    
    self.weightedDataSource.weightedConfigurationBlock = ^(id cell, id sectionKey, id object) {
        
        FAContentTableViewCell *contentCell = cell;
        contentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [contentCell displayContent:object];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayShows
{
    [self.weightedDataSource hideSection:@"movie-recommendations"];
    [self.weightedDataSource showSection:@"show-recommendations"];
    [self.weightedDataSource recalculateWeight];
}

- (void)displayMovies
{
    [self.weightedDataSource hideSection:@"show-recommendations"];
    [self.weightedDataSource showSection:@"movie-recommendations"];
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
    [self.weightedDataSource filterRowsUsingBlock:^BOOL(id key, id obj, BOOL *stop) {
        FATraktContent *content = obj;
        
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
    [detailVC loadContent:object];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)loadRecommendations
{
    [self dispatchAfterViewDidLoad:^{
        [[FATrakt sharedInstance] recommendationsForContentType:FATraktContentTypeShows genre:nil startYear:0 endYear:0 hideCollected:YES hideWatchlisted:YES callback:^(NSArray *recommendations) {
            
            self.showData = recommendations;
            
            [self performBlock:^{
                [self.weightedDataSource createSectionForKey:@"show-recommendations" withWeight:0];
                
                for (NSUInteger i = 0; i < self.showData.count; i++) {
                    
                    FATraktContent *content = self.showData[i];
                    [self.weightedDataSource insertRow:content inSection:@"show-recommendations" withWeight:i];
                }
                
                [self.weightedDataSource recalculateWeight];
            } afterDelay:0];
            
            [self displaySelectedSection];
        } onError:nil];
        
        [[FATrakt sharedInstance] recommendationsForContentType:FATraktContentTypeMovies genre:nil startYear:0 endYear:0 hideCollected:YES hideWatchlisted:YES callback:^(NSArray *recommendations) {
            
            self.movieData = recommendations;
            
            [self performBlock:^{
                [self.weightedDataSource createSectionForKey:@"movie-recommendations" withWeight:0];
                
                for (NSUInteger i = 0; i < self.movieData.count; i++) {
                    
                    FATraktContent *content = self.movieData[i];
                    [self.weightedDataSource insertRow:content inSection:@"movie-recommendations" withWeight:i];
                }
                
                [self.weightedDataSource recalculateWeight];
            } afterDelay:0];
            
            [self displaySelectedSection];
        } onError:nil];
    }];
}

@end
