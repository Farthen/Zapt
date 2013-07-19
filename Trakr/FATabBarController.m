//
//  FATabBarController.m
//  Trakr
//
//  Created by Finn Wilke on 10.09.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATabBarController.h"
#import "FATrakt.h"
#import "FAAppDelegate.h"

@interface FATabBarController ()

@end

@implementation FATabBarController

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*if (![[FATrakt sharedInstance] usernameAndPasswordSaved]) {
        FAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        if (![[FATrakt sharedInstance] usernameAndPasswordSaved]) {
            [delegate handleInvalidCredentials];
        }
    }*/
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
