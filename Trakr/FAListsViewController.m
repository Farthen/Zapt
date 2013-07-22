//
//  FAListsViewController.m
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import "FATraktCache.h"
#import "FAListsViewController.h"
#import "FASearchViewController.h"
#import "FAListDetailViewController.h"
#import "FARefreshControlWithActivity.h"
#import "FAActivityDispatch.h"

@interface FAListsViewController () {
    NSUInteger _refreshCount;
}

@end

@implementation FAListsViewController {
    FATraktList *_watchlist;
}

@dynamic refreshControl;

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
    self.refreshControlWithActivity = [[FARefreshControlWithActivity alloc] init];
    [self.refreshControlWithActivity addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
    
    // Add the refresh control to the activity dispatch to get notified of changes for lists
    [[FAActivityDispatch sharedInstance] registerForActivityName:FATraktActivityNotificationLists observer:self.refreshControlWithActivity];
    
    // Load all the list information to get the count
    if ([FATraktCache sharedInstance].lists.objectCount == 0) {
        [self refreshData];
    }
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
- (void)refreshData
{
    if (_refreshCount == 0) {
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeMovies callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeShows callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [[FATrakt sharedInstance] watchlistForType:FATraktContentTypeEpisodes callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        [[FATrakt sharedInstance] libraryForContentType:FATraktContentTypeMovies libraryType:FATraktLibraryTypeAll detailLevel:FATraktDetailLevelDefault callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [[FATrakt sharedInstance] libraryForContentType:FATraktContentTypeShows libraryType:FATraktLibraryTypeAll detailLevel:FATraktDetailLevelDefault callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [[FATrakt sharedInstance] libraryForContentType:FATraktContentTypeEpisodes libraryType:FATraktLibraryTypeAll detailLevel:FATraktDetailLevelDefault callback:^(FATraktList *list) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
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
        return NSLocalizedString(@"Seen", nil);
    }
    return NSLocalizedString(@"Custom Lists", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if(section == 1) {
        return 2;
    } else if(section == 2) {
        return 0;
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
        cell.textLabel.text = [FATrakt interfaceNameForContentType:type withPlural:YES capitalized:YES];
    }
    FATraktList *cachedList;
    if (indexPath.section == 0) {
        cachedList = [FATraktList cachedListForWatchlistWithContentType:indexPath.row];
    } else {
        cachedList = [FATraktList cachedListForLibraryWithContentType:indexPath.row libraryType:FATraktLibraryTypeAll];
    }
    if (cachedList.items) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", cachedList.items.count];
    } else {
        cell.detailTextLabel.text = nil;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
        FAListDetailViewController *listDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"listdetail"];
        if (indexPath.section == 0) {
            [listDetailViewController loadWatchlistOfType:indexPath.item];
        } else if (indexPath.section == 1) {
            [listDetailViewController loadLibraryOfType:indexPath.item];
        }
        
        [self.navigationController pushViewController:listDetailViewController animated:YES];        
    }
}

@end
