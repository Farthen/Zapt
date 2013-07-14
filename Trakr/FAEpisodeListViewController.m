//
//  FAEpisodeListViewController.m
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAEpisodeListViewController.h"

#import "FATrakt.h"
#import "FAStatusBarSpinnerController.h"
#import "FADetailViewController.h"

@implementation FAEpisodeListViewController {
    FATraktShow *_displayedShow;
    NSMutableArray *_filteredWatchedSeasons;
    NSMutableArray *_filteredWatchedIndexPaths;
    NSMutableArray *_filteredSeasons;
    BOOL _visible;
    
    UIBarButtonItem *_filterWatchedButton;
    BOOL _watchedAny;
    BOOL _filterWatched;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDoneButton:)];
    self.navigationItem.rightBarButtonItem = btnAction;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _visible = true;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchDisplayController setActive:NO animated:NO];
    _visible = false;
}

- (void)populateEpisodeListForShow:(FATraktShow *)show
{
    _displayedShow = show;
    [self.tableView reloadData];
    _watchedAny = NO;
    _filteredWatchedSeasons = [[NSMutableArray alloc] init];
    _filteredWatchedIndexPaths = [[NSMutableArray alloc] init];
    for (int s = 0; s < _displayedShow.seasons.count; s++) {
        FATraktSeason *season = _displayedShow.seasons[s];
        NSMutableArray *filteredEpisodes = [[NSMutableArray alloc] init];
        for (int e = 0; e < season.episodes.count; e++) {
            FATraktEpisode *episode = season.episodes[e];
            if (episode.watched) {
                _watchedAny = YES;
                [_filteredWatchedIndexPaths addObject:[NSIndexPath indexPathForRow:e inSection:s]];
            } else {
                [filteredEpisodes addObject:episode];
            }
        }
        [_filteredWatchedSeasons addObject:filteredEpisodes];
    }
    if (_watchedAny) {
        _filterWatchedButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Watched", nil) style:UIBarButtonItemStylePlain target:self action:@selector(filterWatched)];
        _filterWatched = NO;
        
        _filterWatchedButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Watched", nil), NSLocalizedString(@"All", nil), nil];
        [self.navigationItem setRightBarButtonItem:_filterWatchedButton animated:YES];
    }
}

- (void)filterWatched
{
   [self.tableView beginUpdates];
    if (_filterWatched == YES) {
        _filterWatched = NO;
        _filterWatchedButton.title = NSLocalizedString(@"Watched", nil);
        [self.tableView insertRowsAtIndexPaths:_filteredWatchedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        _filterWatched = YES;
        _filterWatchedButton.title = NSLocalizedString(@"All", nil);
        [self.tableView deleteRowsAtIndexPaths:_filteredWatchedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _displayedShow.seasons.count)] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)showEpisodeListForShow:(FATraktShow *)show
{
    [[FATrakt sharedInstance] showDetailsForShow:show detailLevel:FATraktDetailLevelExtended callback:^(FATraktShow *show) {
        [self populateEpisodeListForShow:show];
    }];
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _filteredSeasons = [[NSMutableArray alloc] init];
    for (int i = 0; i < _displayedShow.seasons.count; i++) {
        FATraktSeason *season = _displayedShow.seasons[i];
        NSMutableArray *filteredEpisodes = [[NSMutableArray alloc] init];
        for (FATraktEpisode *episode in season.episodes) {
            NSString *episodeString = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), season.season.intValue, episode.episode.intValue];
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
    return _displayedShow.seasons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_displayedShow == nil) {
        return 0;
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return ((NSArray *)_filteredSeasons[section]).count;
    }
    if (_filterWatched) {
        return ((NSArray *)_filteredWatchedSeasons[section]).count;
    }
    return ((FATraktSeason *)_displayedShow.seasons[section]).episodes.count;
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
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[indexPath.section];
        episode = episodeArray[indexPath.row];
        season = episode.show.seasons[episode.season.intValue];
    } else {
        season = _displayedShow.seasons[indexPath.section];
        episode = season.episodes[indexPath.row];
    }
    
    cell.textLabel.text = episode.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), season.season.intValue, episode.episode.intValue];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FATraktSeason *season = _displayedShow.seasons[section];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (((NSArray *)_filteredSeasons[section]).count == 0) {
            return nil;
        }
    } else if (_filterWatched) {
        if (((NSArray *)_filteredWatchedSeasons[section]).count == 0) {
            return nil;
        }
    }
    if (season.season.intValue == 0) {
        return NSLocalizedString(@"Specials", nil);
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"Season %@", nil), season.season];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    FATraktSeason *season;
    FATraktEpisode *episode;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[indexPath.section];
        episode = episodeArray[indexPath.row];
        season = episode.show.seasons[episode.season.intValue];
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[indexPath.section];
        episode = episodeArray[indexPath.row];
        season = episode.show.seasons[episode.season.intValue];
    } else {
        season = _displayedShow.seasons[indexPath.section];
        episode = season.episodes[indexPath.row];
    }
    
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    [detailViewController loadContent:episode];
    [self.navigationController pushViewController:detailViewController animated:YES];
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

- (void)dealloc
{
    self.searchDisplayController.delegate = nil;
}

@end
