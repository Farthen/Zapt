//
//  FASeasonListViewController.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonListViewController.h"

#import "FATrakt.h"
#import "FAArrayTableViewDataSource.h"

@interface FASeasonListViewController ()
@property FATraktShow *show;
@property FAArrayTableViewDataSource *arrayDataSource;
@end

@implementation FASeasonListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.arrayDataSource = [[FAArrayTableViewDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.arrayDataSource;
    
    self.arrayDataSource.configurationBlock = ^(UITableViewCell *cell, id object) {
        FATraktSeason *season = object;
        cell.textLabel.text = [NSString stringWithFormat:@"Season %i", season.season.integerValue];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayShow:(FATraktShow *)show
{
    NSArray *sortedSeasonData = [show.seasons sortedArrayUsingKey:@"season" ascending:YES];
    
    self.arrayDataSource.tableViewData = @[sortedSeasonData];
}

- (void)loadShow:(FATraktShow *)show
{    
    if (show.seasons) {
        [self displayShow:show];
    } else {
        [[FATrakt sharedInstance] seasonInfoForShow:show callback:^(FATraktShow *show) {
            if (show.seasons) {
                [self displayShow:show];
            }
        } onError:nil];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

@end
