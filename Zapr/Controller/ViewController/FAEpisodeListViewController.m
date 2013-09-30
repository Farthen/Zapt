//
//  FAEpisodeListViewController.m
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAEpisodeListViewController.h"
#import "FADetailViewController.h"
#import "FAStatusBarSpinnerController.h"
#import "FATrakt.h"

#import "FAUnreadItemIndicatorView.h"

#import "UIView+ImageScreenshot.h"
#import "UIImage+ImageWithColor.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateEpisodeListForShow:_displayedShow];
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
    for (unsigned int s = 0; s < _displayedShow.seasons.count; s++) {
        FATraktSeason *season = _displayedShow.seasons[s];
        NSMutableArray *filteredEpisodes = [[NSMutableArray alloc] init];
        for (unsigned int e = 0; e < season.episodes.count; e++) {
            FATraktEpisode *episode = season.episodes[e];
            if (episode.watched) {
                _watchedAny = YES;
                [_filteredWatchedIndexPaths addObject:[NSIndexPath indexPathForRow:(NSInteger)e inSection:(NSInteger)s]];
            } else {
                [filteredEpisodes addObject:episode];
            }
        }
        [_filteredWatchedSeasons addObject:filteredEpisodes];
    }
    if (_watchedAny) {
        _filterWatchedButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Not watched", nil) style:UIBarButtonItemStylePlain target:self action:@selector(filterWatched)];
        _filterWatched = NO;
        
        _filterWatchedButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Not watched", nil), NSLocalizedString(@"All", nil), nil];
        [self.navigationItem setRightBarButtonItem:_filterWatchedButton animated:YES];
    }
}

- (void)filterWatched
{
   [self.tableView beginUpdates];
    if (_filterWatched == YES) {
        _filterWatched = NO;
        _filterWatchedButton.title = NSLocalizedString(@"Not watched", nil);
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
    [[FATrakt sharedInstance] detailsForShow:show detailLevel:FATraktDetailLevelExtended callback:^(FATraktShow *show) {
        [self populateEpisodeListForShow:show];
    } onError:nil];
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _filteredSeasons = [[NSMutableArray alloc] init];
    for (unsigned int i = 0; i < _displayedShow.seasons.count; i++) {
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
    return (NSInteger)_displayedShow.seasons.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_displayedShow == nil) {
        return 0;
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return (NSInteger)((NSArray *)_filteredSeasons[section]).count;
    }
    if (_filterWatched) {
        return (NSInteger)((NSArray *)_filteredWatchedSeasons[section]).count;
    }
    return (NSInteger)((FATraktSeason *)_displayedShow.seasons[section]).episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_displayedShow == nil) {
        return nil;
    }

    static NSString *cellIdentifier = @"episodeTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    FATraktSeason *season;
    FATraktEpisode *episode;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        season = episode.show.seasons[(NSUInteger)episode.season.intValue];
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        season = episode.show.seasons[(NSUInteger)episode.season.intValue];
    } else {
        season = _displayedShow.seasons[(NSUInteger)indexPath.section];
        episode = season.episodes[(NSUInteger)indexPath.row];
    }
    
    cell.textLabel.text = episode.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), season.season.intValue, episode.episode.intValue];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CGSize imageSize = CGSizeMake(16, self.tableView.rowHeight);
    
    if (episode.watched || ![[FATraktConnection sharedInstance] usernameAndPasswordValid]) {
        cell.imageView.image = [UIImage imageWithColor:[UIColor clearColor] size:imageSize];
    } else {
        static UIImage *image;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            image = [[[FAUnreadItemIndicatorView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)] imageScreenshot];
        });
        cell.imageView.image = image;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FATraktSeason *season = _displayedShow.seasons[(NSUInteger)section];
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
        NSArray *episodeArray = _filteredSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        //season = episode.show.seasons[(NSUInteger)episode.season.intValue];
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        //season = episode.show.seasons[episode.season.unsignedIntValue];
    } else {
        season = _displayedShow.seasons[(NSUInteger)indexPath.section];
        episode = season.episodes[(NSUInteger)indexPath.row];
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
