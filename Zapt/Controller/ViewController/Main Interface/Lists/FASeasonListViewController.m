//
//  FASeasonListViewController.m
//  Zapt
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonListViewController.h"
#import "FASeasonDetailViewController.h"

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
    
    __weak typeof(self) weakSelf = self;
    
    [self setUpRefreshControlWithActivityWithRefreshDataBlock:^(FARefreshControlWithActivity *refreshControlWithActivity) {
        [weakSelf loadShowData:weakSelf.show withActivity:YES];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.rowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.arrayDataSource) {
        self.arrayDataSource = [[FAArrayTableViewDataSource alloc] initWithTableView:self.tableView];
        self.arrayDataSource.cellClass = [FAImageTableViewCell class];
    }
    
    if (!self.arrayTableViewDelegate) {
        self.arrayTableViewDelegate = [[FAArrayTableViewDelegate alloc] initWithDataSource:self.arrayDataSource];
    }
    
    self.arrayTableViewDelegate.delegate = self;
    self.tableView.delegate = self.arrayTableViewDelegate;
    
    [self configureTableViewDataSource];
}

- (void)configureTableViewDataSource
{
    self.arrayDataSource.tableView = self.tableView;
    self.tableView.dataSource = self.arrayDataSource;
    
    __weak typeof(self) weakSelf = self;
    self.arrayDataSource.configurationBlock = ^(FAImageTableViewCell *cell, id key) {
        FATraktSeason *season = [FATraktSeason objectWithCacheKey:key];
        
        cell.textLabel.text = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
        
        UIImage *image = weakSelf.seasonImages[season.seasonNumber];
        
        if (image) {
            cell.imageView.image = image;
        }
        
        cell.detailTextLabel.text = [FAInterfaceStringProvider progressForSeason:season long:YES];
        
        if (season.episodes) {
            if (season.episodesWatched.unsignedIntegerValue >= season.episodeCount.unsignedIntegerValue) {
                [[FABadges instanceForView:cell] badge:FABadgeWatched];
            } else {
                [[FABadges instanceForView:cell] unbadge:FABadgeWatched];
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
    
    self.arrayDataSource.reloadsDataOnDataChange = YES;
    self.arrayTableViewDelegate.dataSource = self.arrayDataSource;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowWithKey:(id)object
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowWithKey:(id)key
{
    FATraktSeason *season = [FATraktSeason objectWithCacheKey:key];
    
    FASeasonDetailViewController *seasonDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"seasonDetail"];
    [seasonDetailVC showEpisodeListForSeason:season];
    [self.navigationController pushViewController:seasonDetailVC animated:YES];
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
                    if (season.seasonNumber) {
                        self.seasonImages[season.seasonNumber] = image;
                        [self.arrayDataSource reloadRowsWithKey:season.cacheKey];
                    }
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
        NSArray *seasonCacheKeys = [sortedSeasonData mapUsingBlock:^id(id obj, NSUInteger idx) {
            return [obj cacheKey];
        }];
        
        self.arrayDataSource.tableViewData = @[seasonCacheKeys];
    }];
}

- (void)loadShowData:(FATraktShow *)show withActivity:(BOOL)activity
{
    if (activity) {
        [self.refreshControlWithActivity startActivity];
    }
    
    [[FATrakt sharedInstance] detailsForShow:show detailLevel:FATraktDetailLevelExtended callback:^(FATraktShow *show) {
        [self.refreshControlWithActivity finishActivity];
        
        if (show.seasons) {
            [self displayShow:show];
        }
    } onError:^(FATraktConnectionResponse *connectionError) {
        [self.refreshControlWithActivity finishActivity];
    }];
}

- (void)loadShow:(FATraktShow *)show
{
    if (show.seasons && show.seasons.count != 0) {
        [self displayShow:show];
    }
    
    [self loadShowData:show withActivity:NO];
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.show forKey:@"show"];
    [coder encodeObject:self.arrayDataSource forKey:@"arrayDataSource"];
    [coder encodeObject:self.seasonImages forKey:@"seasonImages"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.show = [coder decodeObjectForKey:@"show"];
    self.seasonImages = [coder decodeObjectForKey:@"seasonImages"];
    self.arrayDataSource = [coder decodeObjectForKey:@"arrayDataSource"];
    [self configureTableViewDataSource];
    //[self.tableView reloadData];
    //[self loadShow:[coder decodeObjectForKey:@"show"]];
}

@end
