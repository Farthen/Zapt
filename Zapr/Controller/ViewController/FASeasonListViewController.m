//
//  FASeasonListViewController.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonListViewController.h"
#import "FAEpisodeListViewController.h"

#import "FATrakt.h"
#import "FAArrayTableViewDataSource.h"
#import "FAImageTableViewCell.h"
#import "FAInterfaceStringProvider.h"

#import "FARefreshControlWithActivity.h"

#import "FABadges.h"

@interface FASeasonListViewController ()
@property FATraktShow *show;

@property FAArrayTableViewDataSource *arrayDataSource;
@property FAArrayTableViewDelegate *arrayTableViewDelegate;

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
    
    self.refreshControl = [[FARefreshControlWithActivity alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.arrayDataSource = [[FAArrayTableViewDataSource alloc] initWithTableView:self.tableView];
    
    self.arrayTableViewDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
    self.arrayTableViewDelegate.delegate = self;
    self.tableView.delegate = self.arrayTableViewDelegate;
    
    self.tableView.rowHeight = 100;
    
    self.arrayDataSource.cellClass = [FAImageTableViewCell class];
    self.tableView.dataSource = self.arrayDataSource;
    
    __weak typeof(self) weakSelf = self;
    self.arrayDataSource.configurationBlock = ^(FAImageTableViewCell *cell, id object) {
        FATraktSeason *season = object;
        
        cell.textLabel.text = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
        
        UIImage *image = weakSelf.seasonImages[season.seasonNumber];
        
        if (image) {
            cell.imageView.image = image;
        }
        
        cell.detailTextLabel.text = [FAInterfaceStringProvider progressForSeason:season long:YES];
        
        if (season.episodes) {
            if (season.episodesWatched.unsignedIntegerValue >= season.episodeCount.unsignedIntegerValue) {
                [[FABadges instanceForView:cell] badge:FABadgeWatched];
            }
        }
        
        if (season.detailLevel >= FATraktDetailLevelDefault) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowWithObject:(id)object
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowWithObject:(id)object
{
    FATraktSeason *season = object;
    
    FAEpisodeListViewController *episodeListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"episodeList"];
    [episodeListVC showEpisodeListForSeason:season];
    [self.navigationController pushViewController:episodeListVC animated:YES];
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

@end
