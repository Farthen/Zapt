//
//  FAEpisodeListViewController.m
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAEpisodeListViewController.h"

#import "FATrakt.h"
#import "FATraktShow.h"
#import "FATraktSeason.h"
#import "FATraktEpisode.h"
#import "FAStatusBarSpinnerController.h"
#import "FADetailViewController.h"

@implementation FAEpisodeListViewController {
    FATraktShow *_displayedShow;
    NSMutableArray *_filteredSeasons;
    BOOL _visible;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _visible = true;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _visible = false;
}

- (void)populateEpisodeListForShow:(FATraktShow *)show
{
    _displayedShow = show;
    [self.tableView reloadData];
}

- (void)showEpisodeListForShow:(FATraktShow *)show
{
    if (!show.requestedExtendedInformation) {
        //show.requestedExtendedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForShow:show extended:YES callback:^(FATraktShow *show) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self populateEpisodeListForShow:show];
        }];
    } else {
        [self populateEpisodeListForShow:show];
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _filteredSeasons = [[NSMutableArray alloc] init];
    for (int i = 1; i < _displayedShow.seasons.count; i++) {
        FATraktSeason *season = _displayedShow.seasons[i];
        NSMutableArray *filteredEpisodes = [[NSMutableArray alloc] init];
        for (FATraktEpisode *episode in season.episodes) {
            NSString *episodeString = [NSString stringWithFormat:@"S%02iE%02i", season.season.intValue, episode.episode.intValue];
            if ([episode.title.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound ||
                [episodeString.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                [filteredEpisodes addObject:episode];
            }
        }
        [_filteredSeasons addObject:filteredEpisodes];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_displayedShow == nil) {
        return 0;
    }
    return _displayedShow.seasons.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_displayedShow == nil) {
        return 0;
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return ((NSArray *)_filteredSeasons[section]).count;
    }
    return ((FATraktSeason *)_displayedShow.seasons[section + 1]).episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_displayedShow == nil) {
        return nil;
    }

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FATraktSeason *season;
    FATraktEpisode *episode;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[indexPath.section];
        episode = episodeArray[indexPath.row];
        season = episode.show.seasons[episode.season.intValue];
    } else {
        season = _displayedShow.seasons[indexPath.section + 1];
        episode = season.episodes[indexPath.row];
    }
    
    cell.textLabel.text = episode.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"S%02iE%02i", season.season.intValue, episode.episode.intValue];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FATraktSeason *season = _displayedShow.seasons[section + 1];
    return [NSString stringWithFormat:@"Season %@", season.season];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    FATraktSeason *season;
    FATraktEpisode *episode;

    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[indexPath.section];
        episode = episodeArray[indexPath.row];
        season = episode.show.seasons[episode.season.intValue];
    } else {
        season = _displayedShow.seasons[indexPath.section +1];
        episode = season.episodes[indexPath.row];
    }
    [self.searchDisplayController setActive:NO animated:YES];
    [detailViewController showDetailForEpisode:episode];
}

#pragma mark UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    return;
}

@end
