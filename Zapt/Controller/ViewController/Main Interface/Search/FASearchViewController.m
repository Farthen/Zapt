//
//  FASearchViewController.m
//  Zapt
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

static CGPoint _scrollPositions[3];

@interface FASearchViewController ()

@property (nonatomic) FATraktContentType searchScope;

@end

@implementation FASearchViewController {
    FASearchData *_searchData;
    FATraktContentType _searchScope;
    UITableView *_resultsTableView;
    NSMutableArray *_searchRequests;
}

@synthesize searchScope = _searchScope;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.searchData = [[FASearchData alloc] init];
    _searchRequests = [[NSMutableArray alloc] initWithCapacity:3];
    
    self.searchBar.translucent = YES;
    
    _scrollPositions[0] = CGPointZero;
    _scrollPositions[1] = CGPointZero;
    _scrollPositions[2] = CGPointZero;
    
    self.searchDisplayController.searchResultsTableView.restorationIdentifier = @"searchResultsTableView";
    
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
    
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController conformsToProtocol:@protocol(FAViewControllerPreferredContentSizeChanged)]) {
            UIViewController <FAViewControllerPreferredContentSizeChanged> *updatetableViewController = (UIViewController <FAViewControllerPreferredContentSizeChanged> *)viewController;
            [updatetableViewController preferredContentSizeChanged];
        }
    }
}

- (void)navigationControllerPoppedToRootViewControllerNotification:(NSNotification *)notification
{
    [self cancelAllSearchRequests];
    [self.searchDisplayController setActive:NO animated:NO];
}

- (void)cancelAllSearchRequests
{
    @synchronized(self)
    {
        for (FATraktRequest *request in _searchRequests) {
            [request cancelImmediately];
        }
        
        [_searchRequests removeAllObjects];
    }
}

- (void)cleanupRequestArray
{
    // NSMutableArray isn't thread safe
    @synchronized(self)
    {
        for (FATraktRequest *request in _searchRequests) {
            [request cancelImmediately];
        }
        [_searchRequests removeAllObjects];
    }
}

- (void)loadImagesIfNeeded
{
    @synchronized(self) {
        FASearchData *oldSearchData = self.searchData;
        NSArray *visibleIndexPaths = self.searchDisplayController.searchResultsTableView.indexPathsForVisibleRows;
        
        if (self.searchData != oldSearchData) {
            // Prevents a race condition
            return;
        }
        
        FATraktContentType contentType = _searchScope;
        
        [visibleIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = obj;
            NSArray *displayedSearchData = [oldSearchData searchDataForContentType:contentType];
            
            if ((NSInteger)displayedSearchData.count <= indexPath.row) {
                // Just to be sure that we really don't access a wrong index in the array
                return;
            }
            
            FATraktContent *content = displayedSearchData[indexPath.row];
            
            NSString *posterURL = content.posterImageURL;
            
            if (posterURL) {
                [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:42 callback:^(UIImage *image) {
                    @synchronized(self) {
                        if (_searchScope == content.contentType && oldSearchData == self.searchData) {
                            FAContentTableViewCell *cell = (FAContentTableViewCell *)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                            cell.image = image;
                        }
                    }
                } onError:nil];
            }
        }];
    }
}

- (void)searchForString:(NSString *)searchString
{
    DDLogViewController(@"Searching for string: %@", searchString);
    FASearchData *searchData = [[FASearchData alloc] initWithSearchString:searchString];
    self.searchData = searchData;
    
    [_resultsTableView reloadData];
    
    __weak FASearchViewController *weakSelf = self;
    
    FATraktRequest *requestMovies = [[FATrakt sharedInstance] searchMovies:searchString callback:^(FATraktSearchResult *result) {
        searchData.movies = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [weakSelf loadImagesIfNeeded];
    } onError:nil];
    FATraktRequest *requestShows = [[FATrakt sharedInstance] searchShows:searchString callback:^(FATraktSearchResult *result) {
        searchData.shows = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [weakSelf loadImagesIfNeeded];
    } onError:nil];
    FATraktRequest *requestEpisodes = [[FATrakt sharedInstance] searchEpisodes:searchString callback:^(FATraktSearchResult *result) {
        searchData.episodes = result.results;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [weakSelf loadImagesIfNeeded];
    } onError:nil];
    
    [self cleanupRequestArray];
    
    // NSMutableArray isn't thread safe
    @synchronized(self)
    {
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
    } else if (searchScope >= 0 && searchScope <= 2) {
        _scrollPositions[_searchScope] = controller.searchResultsTableView.contentOffset;
        _searchScope = (unsigned int)searchScope;
        [controller.searchResultsTableView setContentOffset:_scrollPositions[searchScope] animated:NO];
        [controller.searchResultsTableView flashScrollIndicators];
        [self loadImagesIfNeeded];
        
        return YES;
    }
    
    return NO;
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
    self.searchData = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchString = searchBar.text;
    [self searchForString:searchString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    UIStoryboard *storyboard = self.storyboard;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self loadImagesIfNeeded];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FAContentTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *cellId = @"FASearchResultTableViewCell";
    FAContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    UIImage *image = nil;
    
    cell.shouldDisplayImage = YES;
    
    if (_searchScope == FATraktContentTypeMovies) {
        FATraktMovie *movie = [self.searchData.movies objectAtIndex:(NSUInteger)indexPath.row];
        image = [movie posterImageWithWidth:42];
        [cell displayContent:movie withImage:image];
    } else if (_searchScope == FATraktContentTypeShows) {
        FATraktShow *show = [self.searchData.shows objectAtIndex:(NSUInteger)indexPath.row];
        image = [show posterImageWithWidth:42];
        [cell displayContent:show withImage:image];
    } else if (_searchScope == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = [self.searchData.episodes objectAtIndex:(NSUInteger)indexPath.row];
        image = [episode posterImageWithWidth:42];
        [cell displayContent:episode withImage:image];
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

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    BOOL active = self.searchDisplayController.active;
    
    [coder encodeBool:active forKey:@"searchDisplayController.active"];
    
    if (active) {
        [coder encodeBool:self.searchBar.isFirstResponder forKey:@"searchBarIsFirstResponder"];
        [coder encodeObject:self.searchData forKey:@"searchData"];
        [coder encodeInteger:_searchScope forKey:@"_searchScope"];
    }
    
    [coder encodeObject:self.childViewControllers[0] forKey:@"childViewController"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    BOOL active = [coder decodeBoolForKey:@"searchDisplayController.active"];
    
    if (active) {
        self.searchData = [coder decodeObjectForKey:@"searchData"];
        _searchScope = [coder decodeIntegerForKey:@"_searchScope"];
        self.searchBar.selectedScopeButtonIndex = _searchScope;
        
        [self.searchDisplayController setActive:YES animated:NO];
        
        if ([coder decodeBoolForKey:@"searchBarIsFirstResponder"]) {
            [self.searchBar becomeFirstResponder];
        }
        
        self.searchBar.text = self.searchData.searchString;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    
    UIViewController *childViewController = [coder decodeObjectForKey:@"childViewController"];
    if (childViewController) {
        [self addChildViewController:childViewController];
    }
}

- (void)dealloc
{
    self.searchDisplayController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
