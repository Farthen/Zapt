//
//  FASeasonDetailViewController.m
//  Zapt
//
//  Created by Finn Wilke on 13/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonDetailViewController.h"
#import "FATrakt.h"
#import "FAProgressHUD.h"
#import "FAInterfaceStringProvider.h"

@interface FASeasonDetailViewController ()
@property (nonatomic) FATraktSeason *season;
@end

@implementation FASeasonDetailViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showEpisodeListForSeason:self.season];
}

- (void)markAllAsSeen
{
    if (!self.season.isWatched) {
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        
        [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Watching the season for you", nil)];
        
        [[FATrakt sharedInstance] setContent:self.season seenStatus:YES callback:^{
            [hud showProgressHUDSuccess];
            [self showEpisodeListForSeason:self.season];
        } onError:^(FATraktConnectionResponse *connectionError) {
            [hud showProgressHUDFailed];
        }];
    }
}

- (void)showEpisodeListForSeason:(FATraktSeason *)season
{
    self.season = season;
    
    self.navigationItem.title = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
    
    [self dispatchAfterViewDidLoad:^{
        [self.episodeListViewController showEpisodeListForSeason:self.season];
        
        if (!self.season.isWatched) {
            UIBarButtonItem *markAsWatchedItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Seen All", nil) style:UIBarButtonItemStylePlain target:self action:@selector(markAllAsSeen)];
            self.navigationItem.rightBarButtonItem = markAsWatchedItem;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
}

- (void)addChildViewController:(UIViewController *)childController
{
    if ([childController isKindOfClass:[FAEpisodeListViewController class]]) {
        self.episodeListViewController = (FAEpisodeListViewController *)childController;
    }
    
    [super addChildViewController:childController];
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.season forKey:@"season"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    [self showEpisodeListForSeason:[coder decodeObjectForKey:@"season"]];
}

@end
