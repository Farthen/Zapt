//
//  FAListsViewController.m
//  Zapt
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAListsViewController.h"
#import "FAListDetailViewController.h"
#import "FASearchViewController.h"
#import "FATrakt.h"
#import "FANewCustomListViewController.h"

#import "FAInterfaceStringProvider.h"
#import "FAProgressHUD.h"
#import "FARefreshControlWithActivity.h"

@interface FAListsViewController ()
@property (nonatomic) UIBarButtonItem *addCustomListButton;
@property (nonatomic) UIActionSheet *deleteListConfirmationActionSheet;
@property (nonatomic) NSIndexPath *listIndexToBeDeleted;
@end

@implementation FAListsViewController {
    FATraktList *_watchlist;
    NSUInteger _refreshCount;
    NSMutableArray *_customLists;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Add a UIRefreshControl (pull to refresh)
    
    self.addCustomListButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCustomListAction)];
    self.navigationItem.rightBarButtonItem = self.addCustomListButton;
    
    self.deleteListConfirmationActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                           destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Load all the list information to get the count
    [self refreshDataAnimated:NO];
}

- (void)addCustomListAction
{
    FANewCustomListViewController *newCustomListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newCustomList"];
    [self presentViewControllerInsideNavigationController:newCustomListVC animated:YES completion:nil];
}

- (void)refreshDataAnimated:(BOOL)animated
{
    if (self.refreshControlWithActivity.startCount == 0) {
        if (animated) {
            [self.refreshControlWithActivity startActivityWithCount:3]; // update this if updating more values
        }
        
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeMovies callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
        
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeShows callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
        
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeEpisodes callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
        
        
        if (animated) {
            [self.refreshControlWithActivity startActivityWithCount:2]; // update this if updating more values
        }
        
        [[FATrakt sharedInstance] libraryForContentType:FATraktContentTypeMovies libraryType:FATraktLibraryTypeAll detailLevel:FATraktDetailLevelDefault callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
        
        [[FATrakt sharedInstance] libraryForContentType:FATraktContentTypeShows libraryType:FATraktLibraryTypeAll detailLevel:FATraktDetailLevelDefault callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
        
        
        if (animated) {
            [self.refreshControlWithActivity startActivity];
        }
        
        [[FATrakt sharedInstance] allCustomListsCallback:^(NSArray *lists) {
            _customLists = [lists mutableCopy];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            
            if (animated) {
                [self.refreshControlWithActivity finishActivity];
            }
        } onError:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedRowIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Watchlists", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Library", nil);
    }
    
    return NSLocalizedString(@"Custom Lists", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        if (!_customLists) {
            _customLists = [[FATraktList cachedCustomLists] mutableCopy];
        }
        
        return (NSInteger)_customLists.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FAListsViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:id];
    }
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        FATraktContentType type = (FATraktContentType)indexPath.item;
        cell.textLabel.text = [FAInterfaceStringProvider nameForContentType:type withPlural:YES capitalized:YES];
    }
    
    FATraktList *cachedList;
    
    if (indexPath.section == 0) {
        cachedList = [FATraktList cachedListForWatchlistWithContentType:indexPath.row];
    } else if (indexPath.section == 1) {
        cachedList = [FATraktList cachedListForLibraryWithContentType:indexPath.row libraryType:FATraktLibraryTypeAll];
    } else if (indexPath.section == 2) {
        cachedList = (FATraktList *)[_customLists objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = cachedList.name;
    }
    
    if (cachedList.items) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (long)cachedList.items.count];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        FAListDetailViewController *listDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listdetail"];
        
        if (indexPath.section == 0) {
            [listDetailViewController loadWatchlistOfType:indexPath.row];
        } else if (indexPath.section == 1) {
            [listDetailViewController loadLibraryOfType:indexPath.row];
        } else if (indexPath.section == 2) {
            [listDetailViewController loadCustomList:[_customLists objectAtIndex:(NSUInteger)indexPath.row]];
        }
        
        [self.navigationController pushViewController:listDetailViewController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 2;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Delete custom list
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 2) {
        FATraktList *list = _customLists[indexPath.row];
        self.deleteListConfirmationActionSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to delete the list \"%@\"?", nil), list.name];
        self.listIndexToBeDeleted = indexPath;
        
        [self.deleteListConfirmationActionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.deleteListConfirmationActionSheet) {
        if (buttonIndex == 0) {
            FAProgressHUD *hud = [[FAProgressHUD alloc] initWithRootView];
            
            FATraktList *list = _customLists[self.listIndexToBeDeleted.row];
            
            [hud showProgressHUDSpinnerWithText:[NSString stringWithFormat:@"Deleting list \"%@\"", list.name]];
            [[FATrakt sharedInstance] removeCustomList:list callback:^{
                [hud showProgressHUDSuccess];
                [_customLists removeObjectAtIndex:self.listIndexToBeDeleted.row];
                [self.tableView deleteRowsAtIndexPaths:@[self.listIndexToBeDeleted] withRowAnimation:UITableViewRowAnimationAutomatic];
            } onError:^(FATraktConnectionResponse *connectionError) {
                [hud showProgressHUDFailed];
            }];
            
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[self.listIndexToBeDeleted] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
