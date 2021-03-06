//
//  FAListDetailViewController.m
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAListDetailViewController.h"
#import "FANewCustomListViewController.h"

#import "FAProgressHUD.h"

#import "FATrakt.h"
#import "FAInterfaceStringProvider.h"
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
    
    BOOL _scrollViewDidScrollOldContentOffset;
    
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
        if (_isWatchlist) {
            _displayedList.items = [_displayedList.items filterUsingBlock:^BOOL(FATraktListItem *item, NSUInteger idx, BOOL *stop) {
                return [item.content.in_watchlist boolValue];
            }];
            
            [self reloadSectionIndexTitleData];
            [self.tableView reloadData];
            
            [self loadWatchlistOfType:_contentType];
        } else if (_isLibrary) {
            FATraktList *collection = _loadedLibrary[FATraktLibraryTypeCollection];
            
            if (![collection isKindOfClass:[NSNull class]]) {
                collection.items = [collection.items filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    FATraktListItem *item = obj;
                    return [item.content.in_collection boolValue];
                }];
            }
            
            
            FATraktList *watchedList = _loadedLibrary[FATraktLibraryTypeWatched];
            if (![watchedList isKindOfClass:[NSNull class]]) {
                watchedList.items = [watchedList.items filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    FATraktListItem *item = obj;
                    return item.content.isWatched;
                }];
            }
            
            FATraktList *allList = _loadedLibrary[FATraktLibraryTypeAll];
            if (![allList isKindOfClass:[NSNull class]]) {
                allList.items = [allList.items filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    FATraktListItem *item = obj;
                    return item.content.isWatched || [item.content.in_collection boolValue];
                }];
            }
            
            [self reloadSectionIndexTitleData];
            [self.tableView reloadData];
            
            [self refreshDataAnimated:NO];
        } else {
            [self refreshDataAnimated:NO];
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
        
        [self filterContentForSearchBar:self.searchBar];
    } else {
        self.searchBar.showsScopeBar = NO;
    }
    
    [self.searchBar invalidateIntrinsicContentSize];
    
    // Show the edit button if the list is a custom list
    if (_isCustom) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCustomList:)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
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

- (void)editCustomList:(UIEvent *)event
{
    FANewCustomListViewController *newListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newCustomList"];
    [newListVC editModeWithList:_loadedList];
    [self presentViewControllerInsideNavigationController:newListVC animated:YES completion:nil];
}

- (void)checkReloadDataForList:(FATraktList *)list
{
    BOOL reloadData = NO;
    
    FATraktList *loadedList;
    
    if (list.isLibrary) {
        if (list.libraryType == FATraktLibraryTypeAll) {
            loadedList = [_loadedLibrary objectAtIndex:(NSUInteger)list.libraryType];
            
            FATraktList *collectedLibrary = [list copy];
            collectedLibrary.items = [list.items filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                FATraktListItem *listItem = obj;
                return [listItem.content.in_collection boolValue];
            }];
            collectedLibrary.libraryType = FATraktLibraryTypeCollection;
            [self checkReloadDataForList:collectedLibrary];
            
            FATraktList *watchedLibrary = [list copy];
            watchedLibrary.items = [list.items filterUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                FATraktListItem *listItem = obj;
                return listItem.content.plays >= 1 && !listItem.content.unseen;
            }];
            watchedLibrary.libraryType = FATraktLibraryTypeWatched;
            [self checkReloadDataForList:watchedLibrary];
        }
        
        
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
        if (list.isLibrary) {
            // This is replacing the libraries at the positions/NSNull with the real objects
            [_loadedLibrary replaceObjectAtIndex:(NSUInteger)list.libraryType withObject:list];
            
            if (_displayedLibraryType == list.libraryType) {
                _displayedList = list;
            }
        } else {
            _loadedList = list;
            _displayedList = _loadedList;
        }
        
        [self reloadSectionIndexTitleData];
        
        [self.tableView reloadData];
        [self loadImagesIfNeeded];
    }
}

- (void)refreshDataAnimated:(BOOL)animated
{
    if (self.refreshControlWithActivity.startCount == 0) {
        if (_isLibrary) {
            if (animated) {
                [self.refreshControlWithActivity startActivity];
            }
            
            [[FATrakt sharedInstance] libraryForContentType:_contentType libraryType:FATraktLibraryTypeAll callback:^(FATraktList *list) {
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
    
    if ([_displayedList isKindOfClass:[FATraktList class]]) {
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
    }
    
    _sortedSectionObjects = [sortedSectionObjects mapUsingBlock:^id(id obj, NSUInteger idx) {
        NSSet *listItems = obj;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"content.title" ascending:YES];
        return [[listItems sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _isWatchlist || (_isLibrary && _displayedLibraryType == FATraktLibraryTypeCollection) || _isCustom;
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *letterList = _sortedSectionObjects[indexPath.section];
    
    NSMutableArray *newList = [NSMutableArray arrayWithArray:letterList];
    
    // Animate the deletion from the table.
    [self.tableView beginUpdates];
    
    [_displayedList.items removeObject:letterList[indexPath.row]];
    [newList removeObjectAtIndex:indexPath.row];
    [_sortedSectionObjects[indexPath.section] removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    // FIXME this should work for library as well
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        
        NSArray *letterList = _sortedSectionObjects[indexPath.section];
        FATraktContent *content = [(FATraktListItem *)letterList[indexPath.row] content];
        
        if (_isWatchlist) {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
            
            [[FATrakt sharedInstance] removeFromWatchlist:content callback:^(void) {
                [hud showProgressHUDSuccess];
                content.in_watchlist = [NSNumber numberWithBool:NO];
                
                // Animate the deletion from the table.
                [self removeItemAtIndexPath:indexPath];
            } onError:^(FATraktConnectionResponse *connectionError) {
                [hud showProgressHUDFailed];
            }];
        } else if (_isLibrary) {
            if (_displayedLibraryType == FATraktLibraryTypeCollection) {
                [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from collection", nil)];
                
                [[FATrakt sharedInstance] removeFromLibrary:content callback:^{
                    [hud showProgressHUDSuccess];
                    
                    content.in_collection = [NSNumber numberWithBool:NO];
                    
                    // Animate the deletion from the table.
                    [self removeItemAtIndexPath:indexPath];
                } onError:^(FATraktConnectionResponse *connectionError) {
                    [hud showProgressHUDFailed];
                }];
            }
        } else if (_isCustom) {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from list", nil)];
            
            [[FATrakt sharedInstance] removeContent:content fromCustomList:_loadedList callback:^{
                [hud showProgressHUDSuccess];
                
                // Animate the deletion from the table.
                [self removeItemAtIndexPath:indexPath];
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

- (void)loadImagesIfNeeded
{
    NSArray *visibleIndexPaths = self.tableView.indexPathsForVisibleRows;
    NSArray *oldSortedSectionObjects = _sortedSectionObjects;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [visibleIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = obj;
            
            FATraktListItem *listItem = [[oldSortedSectionObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            FATraktContent *content = listItem.content;
            
            NSString *posterURL = content.posterImageURL;
            
            if (posterURL) {
                [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:42 callback:^(UIImage *image) {
                    if (_sortedSectionObjects == oldSortedSectionObjects) {
                        FAContentTableViewCell *cell = (FAContentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                        cell.image = image;
                    }
                } onError:nil];
            }
        }];
    });
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
    
    cell.shouldDisplayImage = YES;
    
    FATraktListItem *item = section[indexPath.row];
    [cell displayContent:[item.content cachedVersion]];
    [item.content posterImageWithWidth:42 callback:^(UIImage *image) {
        cell.image = image;
    }];
    
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
    
    if (!scrollView.isDragging) {
        [self loadImagesIfNeeded];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self loadImagesIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesIfNeeded];
    _scrollViewDidScrollOldContentOffset = scrollView.contentOffset.y;
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
        
        if ([loadedList isKindOfClass:[NSNull class]]) {
            return;
        }
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
                NSString *episodeString = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
                
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
    [self loadImagesIfNeeded];
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

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeBool:_isWatchlist forKey:@"_isWatchlist"];
    [coder encodeBool:_isLibrary forKey:@"_isLibrary"];
    [coder encodeBool:_isCustom forKey:@"_isCustom"];
    [coder encodeInteger:_contentType forKey:@"_contentType"];
    [coder encodeObject:self.title forKey:@"title"];
    
    if (_isLibrary) {
        [coder encodeObject:_loadedLibrary forKey:@"_loadedLibrary"];
    } else {
        [coder encodeObject:_loadedList forKey:@"_loadedList"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    _isWatchlist = [coder decodeBoolForKey:@"_isWatchlist"];
    _isLibrary = [coder decodeBoolForKey:@"_isLibrary"];
    _isCustom = [coder decodeBoolForKey:@"_isCustom"];
    _contentType = [coder decodeIntegerForKey:@"_contentType"];
    _reloadWhenShowing = YES;
    self.title = [coder decodeObjectForKey:@"title"];
    
    if (_isLibrary) {
        NSArray *loadedLibrary = [coder decodeObjectForKey:@"_loadedLibrary"];
        for (NSUInteger i = 0; i < 3; i++) {
            FATraktList *list = loadedLibrary[i];
            [self checkReloadDataForList:list];
        }
    } else {
        FATraktList *list = [coder decodeObjectForKey:@"_loadedList"];
        [self checkReloadDataForList:list];
    }
    
    [self refreshDataAnimated:NO];
}

@end
