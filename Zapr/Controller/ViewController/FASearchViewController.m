//
//  FASearchViewController.m
//  Zapr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchViewController.h"
#import "FADetailViewController.h"
#import "FANavigationController.h"
#import "FATrakt.h"
#import "FAActivityDispatch.h"
#import "FANavigationController.h"

#import "FASearchData.h"
#import "FASearchBarWithActivity.h"
#import "FAContentTableViewCell.h"

#import "UIView+Animations.h"

@interface FASearchViewController () {
    FASearchData *_searchData;
    FATraktContentType _searchScope;
    UITableView *_resultsTableView;
    NSMutableArray *_searchRequests;
}

@end

@implementation FASearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searchData = [[FASearchData alloc] init];
    _searchRequests = [[NSMutableArray alloc] initWithCapacity:3];
    
    self.searchBar.translucent = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerPoppedToRootViewControllerNotification:) name:FANavigationControllerDidPopToRootViewControllerNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FAActivityDispatch sharedInstance] registerForActivityName:FATraktActivityNotificationSearch observer:self.searchBar];
    
    // Add constraint to correctly position the UISearchBar
    //NSLayoutConstraint *searchBarConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.navigationController.navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    //[self.view.superview addConstraint:searchBarConstraint];
    
    // Automatically activate the UISearchBar
    //[self.searchDisplayController setActive:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*NSLayoutConstraint *searchBarConstraint = [NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.navigationController.navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view.window addConstraint:searchBarConstraint];*/
    
    //FAAppDelegate *delegate = (FAAppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate performLoginAnimated:YES];
    //[self.searchBar becomeFirstResponder];
    
    if ([self.navigationController isKindOfClass:[FANavigationController class]]) {
        FANavigationController *navigationController = (FANavigationController *)self.navigationController;
        [navigationController addLongButtonTouchGesture];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[FAActivityDispatch sharedInstance] unregister:self.searchBar];
    [self cancelAllSearchRequests];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
    [self.searchBar invalidateIntrinsicContentSize];
}

- (void)preferredContentSizeChanged
{
    [_resultsTableView reloadData];
}

- (void)navigationControllerPoppedToRootViewControllerNotification:(NSNotification *)notification
{
    [self cancelAllSearchRequests];
    [self.searchDisplayController setActive:NO animated:NO];
}

- (void)cancelAllSearchRequests
{
    @synchronized(self) {
        for (FATraktRequest *request in _searchRequests) {
            [request cancelImmediately];
        }
        [_searchRequests removeAllObjects];
    }
}

- (void)removeFinishedRequestsFromRequestArray
{
    // NSMutableArray isn't thread safe
    @synchronized(self) {
        NSMutableIndexSet *removalSet = [NSMutableIndexSet indexSet];
        
        for (NSUInteger i = 0; i < _searchRequests.count; i++) {
            FATraktRequest *request = _searchRequests[i];
            if (request.requestState & FATraktRequestStateFinished) {
                [removalSet addIndex:i];
            }
        }
        
        [_searchRequests removeObjectsAtIndexes:removalSet];
    }
}

- (void)searchForString:(NSString *)searchString
{
    DDLogViewController(@"Searching for string: %@", searchString);
    FASearchData *searchData = [[FASearchData alloc] init];
    self.searchData = searchData;
    
    [_resultsTableView reloadData];
    
    FATraktRequest *requestMovies = [[FATrakt sharedInstance] searchMovies:searchString callback:^(FATraktSearchResult *result) {
        searchData.movies = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    } onError:nil];
    FATraktRequest *requestShows = [[FATrakt sharedInstance] searchShows:searchString callback:^(FATraktSearchResult *result) {
        searchData.shows = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    } onError:nil];
    FATraktRequest *requestEpisodes = [[FATrakt sharedInstance] searchEpisodes:searchString callback:^(FATraktSearchResult *result) {
        searchData.episodes = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
    } onError:nil];
    
    [self removeFinishedRequestsFromRequestArray];
    
    // NSMutableArray isn't thread safe
    @synchronized(self) {
        [_searchRequests addObject:requestMovies];
        [_searchRequests addObject:requestShows];
        [_searchRequests addObject:requestEpisodes];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self cancelAllSearchRequests];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:(NSUInteger)indexPath.row];
        [detailViewController loadContent:movie];
    } else if (_searchScope == FATraktContentTypeShows) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:(NSUInteger)indexPath.row];
        [detailViewController loadContent:show];
    } else if (_searchScope == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:(NSUInteger)indexPath.row];
        [detailViewController loadContent:episode];
    }
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FAContentTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FAContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (!cell) {
        cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    if (_searchScope == FATraktContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:(NSUInteger)indexPath.row];
        [cell displayContent:movie];
    } else if (_searchScope == FATraktContentTypeShows) {
        // TODO: Crashbug here
        FATraktShow *show = [self.searchData.shows objectAtIndex:(NSUInteger)indexPath.row];
        [cell displayContent:show];
    } else if (_searchScope == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:(NSUInteger)indexPath.row];
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
        return (NSInteger)self.searchData.movies.count;
    } else if (_searchScope == FATraktContentTypeShows) {
        return (NSInteger)self.searchData.shows.count;
    } else if (_searchScope == FATraktContentTypeEpisodes) {
        return (NSInteger)self.searchData.episodes.count;
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

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    self.searchDisplayController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
