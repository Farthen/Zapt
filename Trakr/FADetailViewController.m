//
//  FADetailViewController.m
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FADetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "FASearchViewController.h"

#import "FATraktMovie.h"
#import "FATraktPeopleList.h"
#import "FATraktPeople.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

@interface FADetailViewController ()

@end

@implementation FADetailViewController

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

- (void)showDetailForMovie:(FATraktMovie *)movie
{
    self.titleLabel.text = movie.title;
    self.producerLabel.text = [(FATraktPeople *)[movie.people.producers objectAtIndex:0] name];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.releaseDateLabel.text = [dateFormatter stringFromDate:movie.released];
    self.taglineLabel.text = movie.tagline;
}

- (BOOL)shouldPerformSegueWithIdentifier:identifier sender:sender
{
    return YES;
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStylePartialCurl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
