//
//  FAListDetailViewController.m
//  Zapr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAListDetailViewController.h"

#import "FAProgressHUD.h"

#import "FAInterfaceStringProvider.h"
#import "FATrakt.h"
#import "FASearchViewController.h"
#import "FADetailViewController.h"
#import "FAStatusBarSpinnerController.h"
#import "FAContentTableViewCell.h"
#import "FARefreshControlWithActivity.h"

@interface FAListDetailViewController ()

@end

@implementation FAListDetailViewController {
    FATraktList *_displayedList;
    NSArray *_sortedSectionIndexTitles;
    NSMutableArray *_sortedSectionObjects;
    
    FATraktList *_loadedList;
    FATraktLibraryType _displayedLibraryType;
    NSMutableArray *_loadedLibrary;
    BOOL _isWatchlist;
    BOOL _isLibrary;
    BOOL _isCustom;
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
        [self refreshDataAnimated:YES];
    }
}

- (void)preferredContentSizeChanged
{
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Set the row height before loading the tableView for a more smooth experience
    self.tableView.rowHeight = [FAContentTableViewCell cellHeight];
    self.tableView.tableHeaderView = self.searchBar;
    _shouldBeginEditingSearchText = YES;
    
    self.refreshControl = [[FARefreshControlWithActivity alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
    self.tableView.sectionIndexMinimumDisplayRowCount = 20;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Unselect the selected row if any
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedRowIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
    
    if (_reloadWhenShowing) {
        for (unsigned int i = 0; i < _displayedList.items.count; i++) {
            FATraktListItem *item = [_displayedList.items objectAtIndex:i];
            BOOL contentInList = NO;
            
            if (_isWatchlist) {
                contentInList = item.content.in_watchlist;
            } else if (_isLibrary) {
                // FIXME
                contentInList = YES;
            } else if (_isCustom) {
                contentInList = YES;
            }
            
            if (!contentInList) {
                NSMutableArray *newList = [NSMutableArray arrayWithArray:_displayedList.items];
                [newList removeObjectAtIndex:i];
                _displayedList.items = newList;
                
                [self reloadSectionIndexTitleData];
                
                [self.tableView reloadData];
            }
        }
        
        if (_isWatchlist) {
            [self loadWatchlistOfType:_contentType];
        } else if (_isLibrary) {
            [self loadLibraryOfType:_contentType];
        }
    }
    
    if (_isLibrary) {
        self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"All", nil), NSLocalizedString(@"Collected", nil), NSLocalizedString(@"Watched", nil)];
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
        
        [self reloadSectionIndexTitleData];
        
        [self.tableView reloadData];
    }
}

- (void)refreshDataAnimated:(BOOL)animated
{
    if (self.refreshControlWithActivity.startCount == 0) {
        if (_isLibrary) {
            if (animated) {
                [self.refreshControlWithActivity startActivityWithCount:3];
            }
            
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeAll callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                
                if (animated) {
                    [self.refreshControlWithActivity finishActivity];
                }
            } onError:nil];
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeWatched callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                
                if (animated) {
                    [self.refreshControlWithActivity finishActivity];
                }
            } onError:nil];
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeCollection callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                
                if (animated) {
                    [self.refreshControlWithActivity finishActivity];
                }
            } onError:nil];
        } else if (_isWatchlist) {
            if (animated) {
                [self.refreshControlWithActivity startActivity];
            }
            
            [[FATrakt sharedInstance] watchlistForType:_contentType callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                
                if (animated) {
                    [self.refreshControlWithActivity finishActivity];
                }
            } onError:nil];
        } else if (_isCustom) {
            if (animated) {
                [self.refreshControlWithActivity startActivity];
            }
            
            [[FATrakt sharedInstance] detailsForCustomList:_loadedList callback:^(FATraktList *list) {
                [self checkReloadDataForList:list];
                
                if (animated) {
                    [self.refreshControlWithActivity finishActivity];
                }
            } onError:nil];
        }
    }
}

- (void)loadWatchlistOfType:(FATraktContentType)type
{
    _isWatchlist = YES;
    _isLibrary = NO;
    _isCustom = NO;
    _reloadWhenShowing = NO;
    _contentType = type;
    self.title = [NSString stringWithFormat:@"%@ Watchlist", [FAInterfaceStringProvider nameForContentType:type withPlural:YES capitalized:YES]];
    [self refreshDataAnimated:NO];
}

- (void)loadLibraryOfType:(FATraktContentType)type
{
    _isWatchlist = NO;
    _isLibrary = YES;
    _isCustom = NO;
    _reloadWhenShowing = NO;
    _contentType = type;
    _displayedLibraryType = FATraktLibraryTypeAll;
    
    if (!_loadedLibrary) {
        _loadedLibrary = [[NSMutableArray alloc] initWithArray:@[[NSNull null], [NSNull null], [NSNull null]]];
    }
    
    self.title = [NSString stringWithFormat:@"%@ Library", [FAInterfaceStringProvider nameForContentType:type withPlural:YES capitalized:YES]];
    [self refreshDataAnimated:NO];
}

- (void)loadCustomList:(FATraktList *)list
{
    _isWatchlist = NO;
    _isLibrary = NO;
    _isCustom = YES;
    _reloadWhenShowing = NO;
    _contentType = FATraktContentTypeNone;
    _loadedList = list;
    _displayedList = list;
    self.title = list.name;
    [self refreshDataAnimated:NO];
}

- (void)reloadSectionIndexTitleData
{
    _sortedSectionIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                                  @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
    
    NSMutableDictionary * alphabetIndexes = [NSMutableDictionary dictionaryWithCapacity:_sortedSectionIndexTitles.count];
    
    for (NSUInteger i = 0; i < _sortedSectionIndexTitles.count; i++) {
        NSString *alphabetLetter = _sortedSectionIndexTitles[i];
        [alphabetIndexes setObject:[NSNumber numberWithUnsignedInteger:i] forKey:alphabetLetter];
    }
    
    NSMutableArray *sortedSectionObjects = [NSMutableArray arrayWithCapacity:_sortedSectionIndexTitles.count];
    
    for (NSUInteger i = 0; i < _sortedSectionIndexTitles.count; i++) {
        [sortedSectionObjects addObject:[NSMutableSet set]];
    }
    
    for (FATraktListItem *listItem in _displayedList.items) {
        NSString *letter = [[listItem.content.title substringToIndex:1] capitalizedString];
        
        if (letter) {
            NSNumber *sectionIndexNumber = alphabetIndexes[letter];
            
            if (!sectionIndexNumber) {
                // Anything that doesn't fit will go to the label '#'
                sectionIndexNumber = alphabetIndexes[@"#"];
            }
            
            NSMutableSet *listItems = sortedSectionObjects[[sectionIndexNumber unsignedIntegerValue]];
            [listItems addObject:listItem];
        }
    }
    
    _sortedSectionObjects = [sortedSectionObjects mapUsingBlock:^id(id obj, NSUInteger idx) {
        NSSet *listItems = obj;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"content.title" ascending:YES];
        return [listItems sortedArrayUsingDescriptors:@[sortDescriptor]];
    }];    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sortedSectionIndexTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sortedSectionIndexTitles.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    // FIXME this should work for library as well
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_isWatchlist) {
            FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
            
            NSArray *letterList = _sortedSectionObjects[indexPath.section];
            FATraktContent *content = [(FATraktListItem *)letterList[indexPath.row] content];
            
            [[FATrakt sharedInstance] removeFromWatchlist:content callback:^(void) {
                [hud showProgressHUDSuccess];
                content.in_watchlist = NO;
                NSMutableArray *newList = [NSMutableArray arrayWithArray:letterList];
                
                // Animate the deletion from the table.
                [self.tableView beginUpdates];
                [newList removeObjectAtIndex:indexPath.row];
                
                if (newList.count > 0) {
                    [_sortedSectionObjects[indexPath.section] removeObjectAtIndex:indexPath.row];
                    
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    [_sortedSectionObjects removeObjectAtIndex:indexPath.section];
                    //[_sortedSectionIndexTitles removeObjectAtIndex:indexPath.section];
                    
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
                [_displayedList.items removeObject:letterList[indexPath.row]];
                
                [self.tableView endUpdates];
            } onError:^(FATraktConnectionResponse *connectionError) {
                [hud showProgressHUDFailed];
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FAContentTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_displayedList isKindOfClass:[NSNull class]]) {
        return 0;
    }
    
    return [(NSArray *)_sortedSectionObjects[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FAContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    
    if (!cell) {
        cell = [[FAContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    
    NSArray *section = _sortedSectionObjects[indexPath.section];
    
    FATraktListItem *item = section[indexPath.row];
    [cell displayContent:[item.content cachedVersion]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: Crashbug
    UIStoryboard *storyboard = self.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    FATraktListItem *element = _sortedSectionObjects[indexPath.section][indexPath.row];
    
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
                NSString *episodeString = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), episode.seasonNumber.intValue, episode.episodeNumber.intValue];
                
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
    
    [self reloadSectionIndexTitleData];
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
    if (![searchBar isFirstResponder]) {
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

@end
