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

@interface FAListDetailViewController ()

@end

@implementation FAListDetailViewController {
    FATraktList *_displayedList;
    BOOL _isWatchlist;
    FAContentType _watchlistType;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Set the row height before loading the tableView for a more smooth experience
    self.tableView.rowHeight = [FASearchResultTableViewCell cellHeight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    if (_isWatchlist) {
        for (int i = 0; i < _displayedList.items.count; i++) {
            FATraktListItem *item = [_displayedList.items objectAtIndex:i];
            if (!item.content.in_watchlist) {
                NSMutableArray *newList = [NSMutableArray arrayWithArray:_displayedList.items];
                [self.tableView beginUpdates];
                [newList removeObjectAtIndex:i];
                _displayedList.items = newList;
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
        [self loadWatchlistOfType:_watchlistType];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWatchlistOfType:(FAContentType)type
{
    _isWatchlist = YES;
    _watchlistType = type;
    [[FAStatusBarSpinnerController sharedInstance] startActivity];
    [[FATrakt sharedInstance] watchlistForType:type callback:^(FATraktList *list) {
        if (![_displayedList.items isEqualToArray:list.items]) {
            _displayedList = list;
            [self.tableView reloadData];
        }
        [[FAStatusBarSpinnerController sharedInstance] stopAllActivity];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
        [[FATrakt sharedInstance] removeFromWatchlist:[[_displayedList.items objectAtIndex:indexPath.row] content] callback:^(void) {
            [hud showProgressHUDSuccess];
            [[_displayedList.items objectAtIndex:indexPath.row] content].in_watchlist = NO;
            NSMutableArray *newList = [NSMutableArray arrayWithArray:_displayedList.items];
            [self.tableView beginUpdates];
            [newList removeObjectAtIndex:indexPath.row];
            _displayedList.items = newList;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        } onError:^(LRRestyResponse *response) {
            [hud showProgressHUDFailed];
        }];
        // Animate the deletion from the table.
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FASearchResultTableViewCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _displayedList.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Reuse cells
    static NSString *id = @"FASearchResultTableViewCell";
    FASearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (!cell) {
        cell = [[FASearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    
    FATraktListItem *item = [_displayedList.items objectAtIndex:indexPath.item];
    [cell displayContent:item.content];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FADetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detail"];
    
    FATraktListItem *element = [_displayedList.items objectAtIndex:indexPath.row];
    [detailViewController loadContent:element.content];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
