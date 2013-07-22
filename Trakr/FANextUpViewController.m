//
//  FANextUpViewController.m
//  Trakr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FANextUpViewController.h"
#import "FADetailViewController.h"
#import "FAProgressView.h"
#import "FATrakt.h"
#import "UIView+FrameAdditions.h"

@interface FANextUpViewController () {
    BOOL _displaysProgress;
    BOOL _displaysProgressAndNextUp;
}

@end

@implementation FANextUpViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([parent isKindOfClass:[FADetailViewController class]]) {
        FADetailViewController *detailViewController = (FADetailViewController *)parent;
        detailViewController.nextUpViewController = self;
    }
}

- (void)displayProgress:(FATraktShowProgress *)progress
{
    _displaysProgress = YES;
    CGFloat percentage = (CGFloat)progress.percentage.unsignedIntegerValue / 100;
    self.progressView.progress = percentage;
    self.progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Watched %i / %i episodes", nil), progress.completed.unsignedIntegerValue, progress.completed.unsignedIntegerValue + progress.left.unsignedIntegerValue];
}

- (void)displayNextUp:(FATraktContent *)content
{
    _displaysProgressAndNextUp = YES;
    self.episodeNameLabel.text = content.title;
    if (content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        if (episode.season && episode.episode) {
            self.seasonLabel.text = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), episode.season.intValue, episode.episode.intValue];
        }
    }
}

- (CGFloat)intrinsicHeight
{
    CGFloat height = 0;
    if (_displaysProgressAndNextUp) {
        height = 75;
    } else if (_displaysProgress) {
        height = 18;
    }
    return height;
}

@end
