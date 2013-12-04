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
#import "FAImageTableViewCell.h"

@interface FASeasonListViewController ()
@property FATraktShow *show;
@property FAArrayTableViewDataSource *arrayDataSource;
@property NSMutableDictionary *seasonImages;

@property BOOL loadedImageData;
@property BOOL loadedEpisodeData;
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

- (void)setUp
{
    self.navigationItem.title = @"Seasons";
    
    self.seasonImages = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.arrayDataSource = [[FAArrayTableViewDataSource alloc] initWithTableView:self.tableView];
    self.arrayDataSource.cellClass = [FAImageTableViewCell class];
    self.tableView.dataSource = self.arrayDataSource;
    
    __weak typeof(self) weakSelf = self;
    self.arrayDataSource.configurationBlock = ^(FAImageTableViewCell *cell, id object) {
        FATraktSeason *season = object;
        
        if (season.seasonNumber.integerValue == 0) {
            cell.textLabel.text = @"Specials";
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"Season %i", season.seasonNumber.integerValue];
        }
        
        if (weakSelf.seasonImages) {
            UIImage *image = weakSelf.seasonImages[season.seasonNumber];
            
            if (image) {
                cell.imageView.image = image;
            }
        }
        
        if (season.episodes) {
            NSUInteger episodesWatched = season.episodesWatched.unsignedIntegerValue;
            NSUInteger episodesTotal = season.episodeCount.unsignedIntegerValue;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", episodesWatched, episodesTotal];
        }
    };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImageData:(FATraktShow *)show
{
    if (!self.loadedImageData) {
        for (FATraktSeason *season in show.seasons) {
            FATraktImageList *imageList = season.images;
            if (imageList) {
                self.loadedImageData = YES;
                
                [[FATrakt sharedInstance] loadImageFromURL:imageList.poster callback:^(UIImage *image) {
                    self.seasonImages[season.seasonNumber] = image;
                    [self.arrayDataSource reloadRowsWithObject:season];
                } onError:nil];
            }
        }
    }
}

- (void)displayShow:(FATraktShow *)show
{
    self.show = show;
    
    [self loadImageData:show];
    
    [self dispatchAfterViewDidLoad:^{
        NSArray *sortedSeasonData = [show.seasons sortedArrayUsingKey:@"seasonNumber" ascending:YES];
        
        self.arrayDataSource.tableViewData = @[sortedSeasonData];
    }];
}

- (void)loadShow:(FATraktShow *)show
{
    if (show.seasons && show.seasons.count != 0) {
        [self displayShow:show];
    }
    
    [[FATrakt sharedInstance] detailsForShow:show detailLevel:FATraktDetailLevelExtended callback:^(FATraktShow *show) {
        if (show.seasons) {
            [self displayShow:show];
        }
    } onError:nil];
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
