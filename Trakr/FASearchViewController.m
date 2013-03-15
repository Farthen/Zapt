//
//  FASearchViewController.m
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchViewController.h"
#import "FATrakt.h"
#import "FASearchData.h"
#import "FASearchBarWithActivity.h"
#import "FASearchResultTableViewCell.h"

#import "FADetailViewController.h"

#import "FAAppDelegate.h"

@interface FASearchViewController () {
    FASearchData *_searchData;
    FAContentType _searchScope;
    UITableView *_resultsTableView;
}

@end

@implementation FASearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searchData = [[FASearchData alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //FAAppDelegate *delegate = (FAAppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate performLoginAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)searchForString:(NSString *)searchString
{
    [self searchForString:searchString animation:YES];
}

- (void)searchForString:(NSString *)searchString animation:(BOOL)animation
{
    DDLogViewController(@"Searching for string: %@", searchString);
    FASearchData *searchData = [[FASearchData alloc] init];
    self.searchData = searchData;
    
    [_resultsTableView reloadData];
    
    if (animation) {
        [self.searchBar startActivityWithCount:3];
    }
    
    [[FATrakt sharedInstance] searchMovies:searchString callback:^(NSArray *result) {
        searchData.movies = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        if (animation) {
            [self.searchBar finishActivity];
        }
    }];
    [[FATrakt sharedInstance] searchShows:searchString callback:^(NSArray *result) {
        searchData.shows = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        if (animation) {
            [self.searchBar finishActivity];
        }
    }];
    [[FATrakt sharedInstance] searchEpisodes:searchString callback:^(NSArray *result) {
        searchData.episodes = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        if (animation) {
            [self.searchBar finishActivity];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchScope
{
    if (_searchScope == searchScope) {
        return NO;
    } else {
        _searchScope = searchScope;
        return YES;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //[APLog tiny:@"New search string: %@", searchText];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (![searchText isEqualToString:@""]) {
        [self performSelector:@selector(searchForString:) withObject:searchText afterDelay:0.20];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = searchBar.text;
    [self searchForString:searchString animation:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    //[detailViewController view];
    
    if (_searchScope == FAContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        [detailViewController loadContent:movie];
    } else if (_searchScope == FAContentTypeShows) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        [detailViewController loadContent:show];
    } else if (_searchScope == FAContentTypeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:indexPath.row];
        [detailViewController loadContent:episode];
    }
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FASearchResultTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FASearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (!cell) {
        cell = [[FASearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    if (_searchScope == FAContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        [cell displayContent:movie];
    } else if (_searchScope == FAContentTypeShows) {
        // TODO: Crashbug here
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        [cell displayContent:show];
    } else if (_searchScope == FAContentTypeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:indexPath.row];
        [cell displayContent:episode];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _resultsTableView = tableView;
    if (_searchScope == FAContentTypeMovies) {
        return self.searchData.movies.count;
    } else if (_searchScope == FAContentTypeShows) {
        return self.searchData.shows.count;
    } else if (_searchScope == FAContentTypeEpisodes) {
        return self.searchData.episodes.count;
    } else {
        return 0;
    }
}

- (FASearchData *)searchData
{
    return _searchData;
}

- (void)setSearchData:(FASearchData *)searchData
{
    _searchData = searchData;
}

@end
