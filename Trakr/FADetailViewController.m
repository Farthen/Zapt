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
#import "FATraktContentType.h"
#import "FATraktWatchableBaseItem.h"
#import "FATraktMovie.h"
#import "FATraktPeopleList.h"
#import "FATraktImageList.h"
#import "FATraktPeople.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"

@interface FADetailViewController () {
    UIImage *_placeholderImage;
    BOOL _imageLoaded;
    UILabel *_networkLabel;
    UILabel *_episodeNumLabel;
    UILabel *_runtimeLabel;
    UILabel *_directorLabel;
    UILabel *_taglineLabel;
    UILabel *_releaseDateLabel;
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
    
    // Add constraint for minimal size of scroll view content
    NSLayoutConstraint *sizeC = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:sizeC];
    [self.contentView updateConstraintsIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scrollView.contentSize = self.contentView.frame.size;
    [APLog tiny:@"view content size: %f x %f", self.view.frame.size.width, self.view.frame.size.height];
}

- (void)viewWillLayoutSubviews
{
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)setReleaseDate:(NSDate *)date withCaption:(NSString *)caption
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    _releaseDateLabel.text = [NSString stringWithFormat:@"%@: %@", caption, dateString];
    [_releaseDateLabel sizeToFit];
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
    
    _directorLabel.text = directorString;
    [_directorLabel sizeToFit];
}

- (void)setRuntime:(NSNumber *)runtime
{
    NSString *runtimeString = [NSString stringWithFormat:@"Runtime: %@ min", [runtime stringValue]];
    _runtimeLabel.text = runtimeString;
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""]) {
        _imageLoaded = YES;
        [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:0 callback:^(UIImage *image) {
            self.coverImageView.image = image;
            
            // TODO: test
            self.backgroundImageView.image = image;
        }];
    }
}

- (void)setOverview:(NSString *)overview
{
    self.overviewLabel.text = overview;
    [self.overviewLabel sizeToFit];
}

- (void)setTagline:(NSString *)tagline
{
    _taglineLabel.text = tagline;
    [_taglineLabel sizeToFit];
}

- (void)setNetwork:(NSString *)network
{
    _networkLabel.text = [NSString stringWithFormat:@"Network: %@", network];
    [_networkLabel sizeToFit];
}

- (void)setSeasonNum:(NSNumber *)season andEpisodeNum:(NSNumber *)episode
{
    _episodeNumLabel.text = [NSString stringWithFormat:@"Season: %@ Episode: %@", season.stringValue, episode.stringValue];
    [_episodeNumLabel sizeToFit];
}

- (void)loadValueForContent:(FATraktContentType *)item
{
    self.title = item.title;
    [self setPosterToURL:item.images.poster];
    [self setOverview:item.overview];
}

- (void)loadValueForWatchableBaseItem:(FATraktWatchableBaseItem *)item
{
    [self setRuntime:item.runtime];
}

- (void)loadValuesForMovie:(FATraktMovie *)movie
{
    [self loadValueForContent:movie];
    [self loadValueForWatchableBaseItem:movie];
    [self setDirectors:movie.people.directors];
    [self setPosterToURL:movie.images.poster];
    [self setReleaseDate:movie.released withCaption:@"Released"];
    [self setTagline:movie.tagline];
    
    [self viewDidLayoutSubviews];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)showDetailForMovie:(FATraktMovie *)movie
{
    _directorLabel = self.detailLabel1;
    _runtimeLabel = self.detailLabel2;
    _taglineLabel = self.detailLabel3;
    _networkLabel = nil;
    
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

- (void)loadValuesForShow:(FATraktShow *)show
{
    [self loadValueForContent:show];
    [self loadValueForWatchableBaseItem:show];
    [self setNetwork:show.network];
    [self setReleaseDate:show.first_aired withCaption:@"First Aired"];
}

- (void)showDetailForShow:(FATraktShow *)show
{
    _directorLabel = nil;
    _runtimeLabel = self.detailLabel2;
    _networkLabel = self.detailLabel1;
    _releaseDateLabel = self.detailLabel3;
    
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    [[FAStatusBarSpinnerController sharedInstance] startActivity];
    if (!show.requestedDetailedInformation) {
        show.requestedDetailedInformation = YES;
        [[FATrakt sharedInstance] showDetailsForShow:show callback:^(FATraktShow *show) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForShow:show];
        }];
    }
    [self loadValuesForShow:show];
}

- (void)loadValuesForEpisode:(FATraktEpisode *)episode
{
    [self loadValueForContent:episode];
    [self setReleaseDate:episode.first_aired withCaption:@"First Aired"];
}

- (void)showDetailForEpisode:(FATraktEpisode *)episode
{
    _directorLabel = nil;
    _runtimeLabel = self.detailLabel2;
    _networkLabel = self.detailLabel1;
    _episodeNumLabel = self.detailLabel3;
    
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    [[FAStatusBarSpinnerController sharedInstance] startActivity];
    if (!episode.requestedDetailedInformation) {
        episode.requestedDetailedInformation = YES;
        [[FATrakt sharedInstance] showDetailsForEpisode:episode callback:^(FATraktEpisode *episode) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForEpisode:episode];
        }];
    }
    [self loadValuesForEpisode:episode];
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
