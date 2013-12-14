//
//  FAHomeViewController.m
//  Zapr
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAHomeViewController.h"
#import "FANextUpViewController.h"

#import "FATrakt.h"

@interface FAHomeViewController ()
@property FANextUpViewController *currentlyWatchingViewController;
@end

@implementation FAHomeViewController

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
    
    [self loadCurrentlyWatching];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildViewController:(UIViewController *)childController
{
    if ([childController isKindOfClass:[FANextUpViewController class]]) {
        FANextUpViewController *nextUpViewController = (FANextUpViewController *)childController;
        
        if (!self.currentlyWatchingViewController) {
            self.currentlyWatchingViewController = nextUpViewController;
        }
    }
    
    [super addChildViewController:childController];
}

- (void)viewWillLayoutSubviews
{
    self.currentlyWatchingHeightConstraint.constant = self.currentlyWatchingViewController.preferredContentSize.height;
}

- (void)loadCurrentlyWatching
{
    self.currentlyWatchingViewController.nextUpText = NSLocalizedString(@"Watching:", nil);
    
    [[FATrakt sharedInstance] currentlyWatchingContentCallback:^(FATraktContent *content) {
        if ([content isKindOfClass:[FATraktEpisode class]]) {
            [self.currentlyWatchingViewController displayNextUp:(FATraktEpisode *)content];
        }
    } onError:nil];
}

@end
