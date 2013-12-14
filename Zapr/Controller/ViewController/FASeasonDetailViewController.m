//
//  FASeasonDetailViewController.m
//  Zapr
//
//  Created by Finn Wilke on 13/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASeasonDetailViewController.h"

#import "FAInterfaceStringProvider.h"

@interface FASeasonDetailViewController ()

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

- (void)showEpisodeListForSeason:(FATraktSeason *)season
{
    self.navigationItem.title = [FAInterfaceStringProvider nameForSeason:season capitalized:YES];
    
    [self dispatchAfterViewDidLoad:^{
        [self.episodeListViewController showEpisodeListForSeason:season];
    }];
}

- (void)addChildViewController:(UIViewController *)childController
{
    if ([childController isKindOfClass:[FAEpisodeListViewController class]]) {
        self.episodeListViewController = (FAEpisodeListViewController *)childController;
    }
    
    [super addChildViewController:childController];
}

@end
