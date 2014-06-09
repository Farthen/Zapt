//
//  FASeasonDetailViewController.m
//  Zapt
//
//  Created by Finn Wilke on 13/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonDetailViewController.h"
#import <FATrakt/FATrakt.h>
#import "FAProgressHUD.h"

@interface FASeasonDetailViewController ()
@property (nonatomic) FATraktSeason *season;
@property (nonatomic) UIActionSheet *confirmMarkAllAsSeenActionSheet;
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

- (void)setUp
{
    self.confirmMarkAllAsSeenActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Mark as seen", nil) otherButtonTitles:nil];
}

- (void)awakeFromNib
{
    [self setUp];
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

- (void)confirmMarkAllAsSeen
{
    self.confirmMarkAllAsSeenActionSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to mark the entire %@ as seen?", nil), [FAInterfaceStringProvider nameForSeason:self.season capitalized:NO]];
    [self.confirmMarkAllAsSeenActionSheet showInView:self.view];
}

- (void)showEpisodeListForSeason:(FATraktSeason *)season
{
    self.season = season;
    
    self.navigationItem.title = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
    
    [self dispatchAfterViewDidLoad:^{
        [self.episodeListViewController showEpisodeListForSeason:self.season];
        
        if (!self.season.isWatched) {
            UIBarButtonItem *markAsWatchedItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mark Seen", nil) style:UIBarButtonItemStylePlain target:self action:@selector(confirmMarkAllAsSeen)];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.confirmMarkAllAsSeenActionSheet && buttonIndex == 0) {
        [self markAllAsSeen];
    }
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
    [self setUp];
}

@end
