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
    FAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate performLoginIfRequired:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
