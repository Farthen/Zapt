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
#import "FASearchDisplayController.h"

#import "FAInterfaceStringProvider.h"

#import "FAUnreadItemIndicatorView.h"

@implementation FAEpisodeListViewController {
    FATraktShow *_displayedShow;
    NSMutableArray *_filteredWatchedSeasons;
    NSMutableArray *_filteredWatchedIndexPaths;
    NSMutableArray *_filteredSeasons;
    BOOL _visible;
    
    BOOL _displaysSingleSeason;
    FATraktSeason *_displayedSeason;
    
    UIBarButtonItem *_filterWatchedButton;
    BOOL _watchedAny;
    BOOL _notWatchedAny;
    BOOL _filterWatched;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedRowIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
    
    if (_displaysSingleSeason) {
        [self showEpisodeListForSeason:_displayedSeason];
    } else {
        [self showEpisodeListForShow:_displayedShow];
    }
    
    FASearchDisplayController *searchDisplayController = (FASearchDisplayController *)self.searchDisplayController;
    searchDisplayController.hidesNavigationBar = NO;
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

- (void)configureFilterWatchedButton
{
    if (_watchedAny && _notWatchedAny) {
        _filterWatchedButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Not watched", nil) style:UIBarButtonItemStylePlain target:self action:@selector(filterWatched)];
        _filterWatched = NO;
        
        _filterWatchedButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Not watched", nil), NSLocalizedString(@"All", nil), nil];
        [self.navigationItem setRightBarButtonItem:_filterWatchedButton animated:YES];
    }
}

- (void)showEpisodeListForSeason:(FATraktSeason *)season
{
    _displaysSingleSeason = YES;
    _displayedShow = season.show;
    _displayedSeason = season;
    
    _filteredWatchedIndexPaths = [[NSMutableArray alloc] init];
    
    _filteredWatchedSeasons = [NSMutableArray arrayWithObject:[season.episodes filterUsingBlock:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        FATraktEpisode *episode = obj;
        
        if (episode.watched) {
            _watchedAny = YES;
            [_filteredWatchedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            
            return NO;
        }
        
        _notWatchedAny = YES;
        
        return YES;
    }]];
    
    self.navigationItem.title = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
    
    [self configureFilterWatchedButton];
    
    [self.tableView reloadData];
}

- (void)showEpisodeListForShow:(FATraktShow *)show
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
                _notWatchedAny = YES;
                [filteredEpisodes addObject:episode];
            }
        }
        
        [_filteredWatchedSeasons addObject:filteredEpisodes];
    }
    
    [self configureFilterWatchedButton];
    
    [self.tableView reloadData];
}

- (void)filterWatched
{
    [self.tableView beginUpdates];
    
    _filterWatched = !_filterWatched;
    
    if (_filterWatched == NO) {
        _filterWatchedButton.title = NSLocalizedString(@"Not watched", nil);
        [self.tableView insertRowsAtIndexPaths:_filteredWatchedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        _filterWatchedButton.title = NSLocalizedString(@"All", nil);
        [self.tableView deleteRowsAtIndexPaths:_filteredWatchedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (_displaysSingleSeason) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _displayedShow.seasons.count)] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
    
    CGPoint offset = CGPointZero;
    offset.y -= self.tableView.contentInset.top;
    
    [self.tableView setContentOffset:offset animated:YES];
}

- (void)loadEpisodeListForShow:(FATraktShow *)show
{
    [[FATrakt sharedInstance] detailsForShow:show detailLevel:FATraktDetailLevelExtended callback:^(FATraktShow *show) {
        [self showEpisodeListForShow:show];
    } onError:nil];
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    BOOL (^episodeFilterBlock)(FATraktEpisode *obj, NSUInteger idx, BOOL *stop) = ^BOOL (FATraktEpisode *episode, NSUInteger idx, BOOL *stop) {
        NSString *episodeString = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
        
        return [episode.title.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound ||
        [episodeString.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
    };
    
    if (_displaysSingleSeason) {
        _filteredSeasons = [NSMutableArray arrayWithObject:[_displayedSeason.episodes filterUsingBlock:episodeFilterBlock]];
    } else {
        _filteredSeasons = [_displayedShow.seasons mapUsingBlock:^id (FATraktSeason *season, NSUInteger idx) {
            NSMutableArray *filteredEpisodes = [season.episodes filterUsingBlock:episodeFilterBlock];
            
            return filteredEpisodes;
        }];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_displayedShow == nil) {
        return 0;
    }
    
    if (_displaysSingleSeason) {
        return 1;
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
    
    if (_displaysSingleSeason) {
        return _displayedSeason.episodes.count;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FATraktSeason *season;
    FATraktEpisode *episode;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        season = episode.show.seasons[(NSUInteger)episode.seasonNumber.intValue];
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
        season = episode.show.seasons[(NSUInteger)episode.seasonNumber.intValue];
    } else if (_displaysSingleSeason) {
        season = _displayedSeason;
        episode = season.episodes[(NSUInteger)indexPath.row];
    } else {
        season = _displayedShow.seasons[(NSUInteger)indexPath.section];
        episode = season.episodes[(NSUInteger)indexPath.row];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i. %@", episode.episodeNumber.unsignedIntegerValue, episode.title];
    //cell.detailTextLabel.text = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CGSize imageSize = CGSizeMake(16, self.tableView.rowHeight);
    
    if (episode.watched || ![[FATraktConnection sharedInstance] usernameAndPasswordValid]) {
        cell.imageView.image = [UIImage imageWithColor:[UIColor clearColor] size:imageSize];
    } else {
        static UIImage *image;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            FAUnreadItemIndicatorView *indicatorView = [[FAUnreadItemIndicatorView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            
            // This isn't in the view hierarchy so its tintColor property isn't set
            indicatorView.tintColor = self.view.tintColor;
            image = [indicatorView imageScreenshot];
        });
        cell.imageView.image = image;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FATraktSeason *season;
    
    if (_displaysSingleSeason) {
        season = _displayedSeason;
    } else {
        season = _displayedShow.seasons[(NSUInteger)section];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (((NSArray *)_filteredSeasons[section]).count == 0) {
            return nil;
        }
    } else if (_filterWatched) {
        if (((NSArray *)_filteredWatchedSeasons[section]).count == 0) {
            return nil;
        }
    }
    
    if (_displaysSingleSeason) {
        return nil;
    }
    
    return [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FATraktEpisode *episode;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *episodeArray = _filteredSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
    } else if (_filterWatched) {
        NSArray *episodeArray = _filteredWatchedSeasons[(NSUInteger)indexPath.section];
        episode = episodeArray[(NSUInteger)indexPath.row];
    } else if (_displaysSingleSeason) {
        episode = _displayedSeason.episodes[indexPath.row];
    } else {
        FATraktSeason *season = _displayedShow.seasons[(NSUInteger)indexPath.section];
        episode = season.episodes[(NSUInteger)indexPath.row];
    }
    
    UIStoryboard *storyboard = self.storyboard;
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
