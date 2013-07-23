//
//  FAListDetailViewController.m
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAListDetailViewController.h"

#import "FAProgressHUD.h"

#import "FATrakt.h"
#import "FASearchViewController.h"
#import "FADetailViewController.h"
#import "FAStatusBarSpinnerController.h"
#import "FASearchResultTableViewCell.h"
#import "FARefreshControlWithActivity.h"

@interface FAListDetailViewController ()

@end

@implementation FAListDetailViewController {
    FATraktList *_displayedList;
    FATraktList *_loadedList;
    FATraktLibraryType _displayedLibraryType;
    NSMutableArray *_loadedLibrary;
    BOOL _isWatchlist;
    BOOL _isLibrary;
    BOOL _reloadWhenShowing;
    BOOL _shouldBeginEditingSearchText;
    
    FATraktContentType _contentType;
    FATraktLibraryType _libraryType;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setRefreshControlWithActivity:(FARefreshControlWithActivity *)refreshControlWithActivity
{
    self.refreshControl = refreshControlWithActivity;
}

- (FARefreshControlWithActivity *)refreshControlWithActivity
{
    if ([self.refreshControl isKindOfClass:[FARefreshControlWithActivity class]]) {
        return (FARefreshControlWithActivity *)self.refreshControl;
    } else {
        return nil;
    }
}

- (void)refreshControlValueChanged
{
    if (self.refreshControl.refreshing) {
        [self refreshData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Set the row height before loading the tableView for a more smooth experience
    self.tableView.rowHeight = [FASearchResultTableViewCell cellHeight];
    self.tableView.tableHeaderView = self.searchBar;
    _shouldBeginEditingSearchText = YES;
    
    self.refreshControl = [[FARefreshControlWithActivity alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    if (_reloadWhenShowing) {
        for (unsigned int i = 0; i < _displayedList.items.count; i++) {
            FATraktListItem *item = [_displayedList.items objectAtIndex:i];
            BOOL contentInList = NO;
            if (_isWatchlist) {
                contentInList = item.content.in_watchlist;
            } else if (_isLibrary) {
                contentInList = YES;
            }
            if (!contentInList) {
                NSMutableArray *newList = [NSMutableArray arrayWithArray:_displayedList.items];
                [self.tableView beginUpdates];
                [newList removeObjectAtIndex:i];
                _displayedList.items = newList;
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
        if (_isWatchlist) {
            [self loadWatchlistOfType:_contentType];
        } else if (_isLibrary){
            [self loadLibraryOfType:_contentType];
        }
    }
    
    if (_isLibrary) {
        self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"All", nil), NSLocalizedString(@"Watched", nil), NSLocalizedString(@"Collection", nil)];
        self.searchBar.showsScopeBar = YES;
        self.tableView.tableHeaderView = self.searchBar;
        [self.searchBar sizeToFit];
        self.searchBar.tintColor = nil;
        [self.searchBar setNeedsDisplay];
        [self.searchBar invalidateIntrinsicContentSize];
        [self.searchBar layoutIfNeeded];
        [self.tableView layoutIfNeeded];
        self.tableView.tableHeaderView = self.searchBar;
    } else {
        self.searchBar.showsScopeBar = NO;
    }
    
    [self.searchBar invalidateIntrinsicContentSize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _reloadWhenShowing = YES;
    //[self.searchDisplayController setActive:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkReloadDataForList:(FATraktList *)list
{
    BOOL reloadData = NO;
    
    FATraktList *loadedList;
    if (list.isLibrary) {
        loadedList = [_loadedLibrary objectAtIndex:(NSUInteger)list.libraryType];
        if ([loadedList isMemberOfClass:[NSNull class]]) {
            loadedList = nil;
        }
    } else {
        loadedList = _loadedList;
    }
    
    if (loadedList.items.count == list.items.count) {
        for (unsigned int i = 0; i < loadedList.items.count; i++) {
            if (((FATraktListItem *)loadedList.items[i]).content != [((FATraktListItem *)list.items[i]).content cachedVersion]) {
                reloadData = YES;
                break;
            }
        }
    } else {
        reloadData = YES;
    }
    
    if (reloadData) {
        _loadedList = list;
        if (list.isLibrary) {
            // This is replacing the libraries at the positions/NSNull with the real objects
            [_loadedLibrary replaceObjectAtIndex:(NSUInteger)list.libraryType withObject:list];
            if (_displayedLibraryType == list.libraryType) {
                _displayedList = _loadedList;
            }
        } else {
            _loadedList = list;
            _displayedList = _loadedList;
        }
        [self.tableView reloadData];
    }
}

- (void)refreshData
{
    if (self.refreshControlWithActivity.startCount == 0) {
        if (_isLibrary) {
            [self.refreshControlWithActivity startActivityWithCount:3];
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeAll callback:^(FATraktList *list){
                [self checkReloadDataForList:list];
                [self.refreshControlWithActivity finishActivity];
            }];
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeWatched callback:^(FATraktList *list){
                [self checkReloadDataForList:list];
                [self.refreshControlWithActivity finishActivity];
            }];
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeCollection callback:^(FATraktList *list){
                [self checkReloadDataForList:list];
                [self.refreshControlWithActivity finishActivity];
            }];
        } else if (_isWatchlist) {
            [self.refreshControlWithActivity startActivity];
            [[FATrakt sharedInstance] watchlistForType:_contentType callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                [self.refreshControlWithActivity finishActivity];
            }];
        }
    }
}

- (void)loadWatchlistOfType:(FATraktContentType)type
{
    _isWatchlist = YES;
    _isLibrary = NO;
    _reloadWhenShowing = NO;
    _contentType = type;
    self.title = [NSString stringWithFormat:@"%@ Watchlist", [FATrakt interfaceNameForContentType:type withPlural:YES capitalized:YES]];
    [self refreshData];
}

- (void)loadLibraryOfType:(FATraktContentType)type
{
    _isWatchlist = NO;
    _isLibrary = YES;
    _reloadWhenShowing = NO;
    _contentType = type;
    _displayedLibraryType = FATraktLibraryTypeAll;
    if (!_loadedLibrary) {
        _loadedLibrary = [[NSMutableArray alloc] initWithArray:@[[NSNull null], [NSNull null], [NSNull null]]];
    }
    
    self.title = [NSString stringWithFormat:@"%@ Library", [FATrakt interfaceNameForContentType:type withPlural:YES capitalized:YES]];
    [self refreshData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
        [[FATrakt sharedInstance] removeFromWatchlist:[[_displayedList.items objectAtIndex:(NSUInteger)indexPath.row] content] callback:^(void) {
            [hud showProgressHUDSuccess];
            [[_displayedList.items objectAtIndex:indexPath.row] content].in_watchlist = NO;
            NSMutableArray *newList = [NSMutableArray arrayWithArray:_displayedList.items];
            
            // Animate the deletion from the table.
            [self.tableView beginUpdates];
            [newList removeObjectAtIndex:(NSUInteger)indexPath.row];
            _displayedList.items = newList;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
        } onError:^(LRRestyResponse *response) {
            [hud showProgressHUDFailed];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FASearchResultTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_displayedList isKindOfClass:[NSNull class]]) {
        return 0;
    }
    return (NSInteger)_displayedList.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FASearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (!cell) {
        cell = [[FASearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    
    FATraktListItem *item = [_displayedList.items objectAtIndex:(NSUInteger)indexPath.item];
    [cell displayContent:[item.content cachedVersion]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: Crashbug
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    FATraktListItem *element = [_displayedList.items objectAtIndex:(NSUInteger)indexPath.row];
    [detailViewController loadContent:element.content];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark Search
- (void)filterContentForSearchBar:(UISearchBar *)searchBar
{
    NSString *searchText = searchBar.text;
    
    FATraktList *loadedList = _loadedList;
    if (_isLibrary) {
        FATraktLibraryType libraryType = searchBar.selectedScopeButtonIndex;
        loadedList = [_loadedLibrary objectAtIndex:(NSUInteger)libraryType];
        _displayedLibraryType = libraryType;
    }
    
    FATraktList *displayedList = [loadedList copy];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (searchText && ![searchText isEqualToString:@""]) {
        for (unsigned int i = 0; i < loadedList.items.count; i++) {
            FATraktListItem *listItem = loadedList.items[i];
            FATraktContent *content = listItem.content;
            BOOL add = NO;
            if (content.contentType == FATraktContentTypeEpisodes) {
                FATraktEpisode *episode = (FATraktEpisode *)content;
                NSString *episodeString = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), episode.season.intValue, episode.episode.intValue];
                if ([episodeString.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound ||
                    [episode.show.title.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                    add = YES;
                }
            }
            if ([content.title.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                add = YES;
            }
            
            if (add) {
                [items addObject:listItem];
            }
        }
        displayedList.items = items;
    }
    
    _displayedList = displayedList;
    
    [self.tableView reloadData];
}


#pragma mark - UISearchBarDelegate Methods
// React to any delegate method we are interested in and change whatever needs changing
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
    
    searchBar.text = nil;
    [self filterContentForSearchBar:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!_shouldBeginEditingSearchText) {
        _shouldBeginEditingSearchText = YES;
        return NO;
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // http://stackoverflow.com/questions/1092246/uisearchbar-clearbutton-forces-the-keyboard-to-appear/3852509#3852509
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        _shouldBeginEditingSearchText = NO;
    }
    // do whatever I want to happen when the user clears the search...
    [self filterContentForSearchBar:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self filterContentForSearchBar:searchBar];
}

- (void)dealloc
{
    //self.searchBar.delegate = nil;
}

@end
