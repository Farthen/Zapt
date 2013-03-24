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
#import "FAActivityDispatch.h"

#import "FADetailViewController.h"

#import "FAAppDelegate.h"

@interface FASearchViewController () {
    FASearchData *_searchData;
    FATraktContentType _searchScope;
    UITableView *_resultsTableView;
}

@end

@implementation FASearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searchData = [[FASearchData alloc] init];
    
    [[FAActivityDispatch sharedInstance] registerForActivityName:FATraktActivityNotificationSearch observer:self.searchBar];
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
    
    [[FAActivityDispatch sharedInstance] unregister:self.searchBar];
}

- (void)searchForString:(NSString *)searchString
{
    DDLogViewController(@"Searching for string: %@", searchString);
    FASearchData *searchData = [[FASearchData alloc] init];
    self.searchData = searchData;
    
    [_resultsTableView reloadData];
    
    [[FATrakt sharedInstance] searchMovies:searchString callback:^(FATraktSearchResult *result) {
        searchData.movies = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    [[FATrakt sharedInstance] searchShows:searchString callback:^(FATraktSearchResult *result) {
        searchData.shows = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    [[FATrakt sharedInstance] searchEpisodes:searchString callback:^(FATraktSearchResult *result) {
        searchData.episodes = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
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
    [self searchForString:searchString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    //[detailViewController view];
    
    if (_searchScope == FATraktContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        [detailViewController loadContent:movie];
    } else if (_searchScope == FATraktContentTypeShows) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        [detailViewController loadContent:show];
    } else if (_searchScope == FATraktContentTypeEpisodes) {
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
    if (_searchScope == FATraktContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        [cell displayContent:movie];
    } else if (_searchScope == FATraktContentTypeShows) {
        // TODO: Crashbug here
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        [cell displayContent:show];
    } else if (_searchScope == FATraktContentTypeEpisodes) {
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
    if (_searchScope == FATraktContentTypeMovies) {
        return self.searchData.movies.count;
    } else if (_searchScope == FATraktContentTypeShows) {
        return self.searchData.shows.count;
    } else if (_searchScope == FATraktContentTypeEpisodes) {
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
