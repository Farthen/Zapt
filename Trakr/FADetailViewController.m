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
#import "FAStatusBarSpinnerController.h"
#import "UIView+SizeToFitSubviews.h"

#import "FATrakt.h"
#import "FATraktMovie.h"
#import "FATraktPeopleList.h"
#import "FATraktImageList.h"
#import "FATraktPeople.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

@interface FADetailViewController () {
    UIImage *_placeholderImage;
    BOOL _imageLoaded;
}

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

- (void)awakeFromNib
{
    _placeholderImage = self.coverImageView.image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize = self.contentView.frame.size;
    NSLog(@"view content size: %f x %f", self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewDidLayoutSubviews
{
    [self.taglineLabel sizeToFit];
    [self.contentView resizeToFitSubviewsWithMinimumSize:self.scrollView.frame.size];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)setReleaseDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.releaseDateLabel.text = [dateFormatter stringFromDate:date];
    [self.releaseDateLabel sizeToFit];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

- (void)setDirectors:(NSArray *)directors
{
    NSMutableString *directorString = [[NSMutableString alloc] init];
    for (FATraktPeople *people in directors) {
        if ([directorString isEqualToString:@""]) {
            [directorString appendString:people.name];
        } else {
            [directorString appendFormat:@", %@", people.name];
        }
    }
    
    self.directorLabel.text = directorString;
    [self.directorLabel sizeToFit];
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""]) {
        _imageLoaded = YES;
        [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:138 callback:^(UIImage *image) {
            self.coverImageView.image = image;
        }];
    }
}

- (void)setTagline:(NSString *)tagline
{
    self.taglineLabel.text = tagline;
    [self.taglineLabel sizeToFit];
}

- (void)loadValuesForMovie:(FATraktMovie *)movie
{
    [self setTitle:movie.title];
    [self setDirectors:movie.people.directors];
    [self setPosterToURL:movie.images.poster];
    [self setReleaseDate:movie.released];
    [self setTagline:movie.tagline];
    
    [self.contentView sizeToFit];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)showDetailForMovie:(FATraktMovie *)movie
{
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    [[FAStatusBarSpinnerController sharedInstance] startActivity];
    if (!movie.requestedDetailedInformation) {
        movie.requestedDetailedInformation = YES;
        [[FATrakt sharedInstance] movieDetailsForMovie:movie callback:^(FATraktMovie *movie) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForMovie:movie];
        }];
    }
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Movie", nil);
    [self loadValuesForMovie:movie];
}

- (void)showDetailForShow:(FATraktShow *)show
{
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
