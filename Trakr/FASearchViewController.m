//
//  FAFirstViewController.m
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

#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktPeopleList.h"
#import "FATraktPeople.h"

@interface FASearchViewController () {
    FASearchData *_searchData;
    NSInteger _searchScope;
}

@end

@implementation FASearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searchData = [[FASearchData alloc] init];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
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
    NSLog(@"New search string: %@", searchText);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = searchBar.text;
    NSLog(@"Searching for string: %@", searchString);
    FASearchData *searchData = [[FASearchData alloc] init];
    self.searchData = searchData;
    
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
    if (_searchScope == 0) {
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
    } else if (_searchScope == 1) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:indexPath.row];
        cell.textLabel.text = show.title;
        NSString *genres = [show.genres componentsJoinedByString:@", "];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:show.first_aired];
        NSString *detailString = [NSString stringWithFormat:@"%i – %@", components.year, genres];
        cell.leftAuxiliaryTextLabel.text = detailString;
        cell.detailTextLabel.text = show.overview;
    } else if (_searchScope == 2) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:indexPath.row];
        cell.textLabel.text = episode.title;
        cell.leftAuxiliaryTextLabel.text = episode.show.title;
        if (episode.overview) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"S%@E%@ – %@", episode.season, episode.episode, episode.overview];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"S%@E%@", episode.season, episode.episode];
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
    if (_searchScope == 0) {
        return self.searchData.movies.count;
    } else if (_searchScope == 1) {
        return self.searchData.shows.count;
    } else if (_searchScope == 2) {
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
