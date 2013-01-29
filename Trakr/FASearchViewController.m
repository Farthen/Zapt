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

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktPeopleList.h"
#import "FATraktPeople.h"

@interface FASearchViewController () {
    FASearchData *_searchData;
    FASearchScope _searchScope;
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
    [APLog tiny:@"New search string: %@", searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = searchBar.text;
    [APLog fine:@"Searching for string: %@", searchString];
    FASearchData *searchData = [[FASearchData alloc] init];
    self.searchData = searchData;
    [_resultsTableView reloadData];
    
    [self.searchBar startActivityWithCount:3];
    
    [[FATrakt sharedInstance] searchMovies:searchString callback:^(NSArray *result) {
        searchData.movies = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchBar finishActivity];
    }];
    [[FATrakt sharedInstance] searchShows:searchString callback:^(NSArray *result) {
        searchData.shows = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchBar finishActivity];
    }];
    [[FATrakt sharedInstance] searchEpisodes:searchString callback:^(NSArray *result) {
        searchData.episodes = result;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchBar finishActivity];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    if (_searchScope == FASearchScopeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        [detailViewController showDetailForMovie:movie];
    } else if (_searchScope == FASearchScopeShows) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        [detailViewController showDetailForShow:show];
    } else if (_searchScope == FASearchScopeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:indexPath.row];
        [detailViewController showDetailForEpisode:episode];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FASearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (!cell) {
        cell = [[FASearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    if (_searchScope == FASearchScopeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:indexPath.row];
        cell.textLabel.text = movie.title;
        NSString *genres = [movie.genres componentsJoinedByString:@", "];
        NSString *detailString;
        if (movie.year && ![genres isEqualToString:@""]) {
            detailString = [NSString stringWithFormat:@"%@ - %@", movie.year, genres];
        } else if (movie.year) {
            detailString = [NSString stringWithFormat:@"%@", movie.year];
        } else if (![genres isEqualToString:@""]) {
            detailString = [NSString stringWithFormat:@"%@", genres];
        } else {
            detailString = @"";
        }
        
        cell.leftAuxiliaryTextLabel.text = detailString;
        NSString *tagline = movie.tagline;
        cell.detailTextLabel.text = tagline;
    } else if (_searchScope == FASearchScopeShows) {
        // TODO: Crashbug here
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        cell.textLabel.text = show.title;
        NSString *genres = [show.genres componentsJoinedByString:@", "];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:show.first_aired];
        NSString *detailString = [NSString stringWithFormat:@"%i – %@", components.year, genres];
        cell.leftAuxiliaryTextLabel.text = detailString;
        cell.detailTextLabel.text = show.overview;
    } else if (_searchScope == FASearchScopeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:indexPath.row];
        cell.textLabel.text = episode.title;
        cell.leftAuxiliaryTextLabel.text = episode.show.title;
        if (episode.overview) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"S%02iE%02i – %@", episode.season.intValue, episode.episode.intValue, episode.overview];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"S%02iE%02i", episode.season.intValue, episode.episode.intValue];
        }
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
    if (_searchScope == FASearchScopeMovies) {
        return self.searchData.movies.count;
    } else if (_searchScope == FASearchScopeShows) {
        return self.searchData.shows.count;
    } else if (_searchScope == FASearchScopeEpisodes) {
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
