//
//  FAListsViewController.m
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATrakt.h"
#import "FAListsViewController.h"
#import "FASearchViewController.h"
#import "FAListDetailViewController.h"

@interface FAListsViewController ()

@end

@implementation FAListsViewController {
    FATraktList *_watchlist;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Unselect the selected row if any
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Watchlists";
    }
    return @"Custom Lists";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if(section == 1) {
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    if (indexPath.section == 0) {
        if(indexPath.item == FAContentTypeMovies) {
            cell.textLabel.text = @"Movies";
        } else if(indexPath.item == FAContentTypeShows) {
            cell.textLabel.text = @"Shows";
        } else if(indexPath.item == FAContentTypeEpisodes) {
            cell.textLabel.text = @"Episodes";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
        FAListDetailViewController *listDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"listdetail"];
        [self.navigationController pushViewController:listDetailViewController animated:YES];
        
        if (indexPath.section == 0) {
            [listDetailViewController loadWatchlistOfType:indexPath.item];
        }
    }
}

@end
