//
//  FARatingsViewController.m
//  Zapr
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FARatingsViewController.h"
#import "FARatingsView.h"
#import "FATrakt.h"

@interface FARatingsViewController ()
@property FATraktContent *currentContent;
@property FARatingsView *ratingsView;
@property FATraktAccountSettings *accountSettings;
@end

@implementation FARatingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.ratingsView = [[FARatingsView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.ratingsView];
        self.ratingsView.delegate = self;
    }
    return self;
}

- (instancetype)initWithContent:(FATraktContent *)content
{
    self = [super init];
    if (self) {
        self.currentContent = content;
        
        [[FATrakt sharedInstance] loadImageFromURL:content.widescreenImageURL withWidth:self.view.bounds.size.width callback:^(UIImage *image) {
            [self.ratingsView setColorsWithImage:image];
        } onError:^(FATraktConnectionResponse *connectionError) {
            [self.ratingsView setColorsWithImage:nil];
        }];
        [[FATrakt sharedInstance] accountSettings:^(FATraktAccountSettings *settings) {
            self.accountSettings = settings;
            FATraktRatingsMode mode = self.accountSettings.viewing.ratings_mode;
            if (mode == FATraktRatingsModeSimple) {
                [self.ratingsView setSimpleRating:YES];
            } else {
                [self.ratingsView setSimpleRating:NO];
            }
            [self.ratingsView setRating:content.rating];
        } onError:nil];
    }
    return self;
}

- (void)ratingsViewDoneButtonPressed:(id)sender
{
    FATraktRating rating = self.ratingsView.rating;

    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.accountSettings.viewing.ratings_mode == FATraktRatingsModeSimple) {
        [[FATrakt sharedInstance] rate:self.currentContent simple:YES rating:rating callback:^{} onError:nil];
    } else {
        [[FATrakt sharedInstance] rate:self.currentContent simple:NO rating:rating callback:^{} onError:nil];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
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

@end
