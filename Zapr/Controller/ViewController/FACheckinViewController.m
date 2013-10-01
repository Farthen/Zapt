//
//  FACheckinViewController.m
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACheckinViewController.h"

@interface FACheckinViewController ()
@property CGFloat progress;
@end

@implementation FACheckinViewController

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
    
    self.progressView.progress = self.progress;
    self.progressView.label.text = @"Time remaining:\n30 seconds";
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProgress:(CGFloat)progress
{
    self.progress = progress;
}

@end
