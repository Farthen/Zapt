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

@interface FATabBarController () {
    BOOL _initialLoginDone;
}

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
    _initialLoginDone = NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_initialLoginDone) {
        _initialLoginDone = YES;
        FAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate performInitialLogin:self];
    }
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
