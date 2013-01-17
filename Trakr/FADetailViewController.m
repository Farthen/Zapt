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

#import "FASearchViewController.h"
#import "FAEpisodeListViewController.h"

#import "FATrakt.h"
#import "FATraktContentType.h"
#import "FATraktWatchableBaseItem.h"
#import "FATraktMovie.h"
#import "FATraktPeopleList.h"
#import "FATraktImageList.h"
#import "FATraktPeople.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktSeason.h"

@interface FADetailViewController () {
    FASearchScope _contentType;
    FATraktContentType *_currentContent;
    UIImage *_placeholderImage;
    BOOL _imageLoaded;
    UILabel *_networkLabel;
    UILabel *_episodeNumLabel;
    UILabel *_runtimeLabel;
    UILabel *_directorLabel;
    UILabel *_taglineLabel;
    UILabel *_releaseDateLabel;
    UILabel *_showNameLabel;
    UILabel *_airTimeLabel;
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
    [self.contentView updateConstraintsIfNeeded];
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
    [_runtimeLabel sizeToFit];
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""]) {
        _imageLoaded = YES;
        [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:0 callback:^(UIImage *image) {
            self.coverImageView.image = image;
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

- (void)setShowName:(NSString *)showName
{
    _showNameLabel.text = showName;
    [_showNameLabel sizeToFit];
}

- (void)setAirDay:(NSString *)day andTime:(NSString *)time
{
    _airTimeLabel.text = [NSString stringWithFormat:@"Airs %@ at %@", day, time];
    [_airTimeLabel sizeToFit];
}

- (void)loadValueForContent:(FATraktContentType *)item
{
    self.title = item.title;
    [self setOverview:item.overview];
}

- (void)loadValueForWatchableBaseItem:(FATraktWatchableBaseItem *)item
{
    [self setRuntime:item.runtime];
    [self setPosterToURL:item.images.poster];
}

- (void)loadValuesForMovie:(FATraktMovie *)movie
{
    [self loadValueForContent:movie];
    [self loadValueForWatchableBaseItem:movie];
    [self setDirectors:movie.people.directors];
    [self setReleaseDate:movie.released withCaption:@"Released"];
    [self setTagline:movie.tagline];
    
    [self viewDidLayoutSubviews];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)showDetailForMovie:(FATraktMovie *)movie
{
    _contentType = FASearchScopeMovies;
    _currentContent = movie;
    _directorLabel = self.detailLabel1;
    _runtimeLabel = self.detailLabel2;
    _releaseDateLabel = self.detailLabel3;
    _taglineLabel = self.detailLabel4;
    _networkLabel = nil;
    
    self.actionButton.title = @"Check In";
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    if (!movie.requestedDetailedInformation) {
        movie.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
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
    [self setAirDay:show.air_day andTime:show.air_time];
}

- (void)showDetailForShow:(FATraktShow *)show
{
    _contentType = FASearchScopeShows;
    _currentContent = show;
    _directorLabel = nil;
    
    _runtimeLabel = self.detailLabel2;
    _networkLabel = self.detailLabel1;
    _releaseDateLabel = self.detailLabel3;
    _airTimeLabel = self.detailLabel4;
    
    self.actionButton.title = @"Episodes";
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    if (!show.requestedDetailedInformation) {
        show.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForShow:show callback:^(FATraktShow *show) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForShow:show];
        }];
    }
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Show", nil);
    [self loadValuesForShow:show];
}

- (void)loadValuesForEpisode:(FATraktEpisode *)episode
{
    [self loadValueForContent:episode];
    [self setShowName:episode.show.title];
    [self setNetwork:episode.show.network];
    [self setRuntime:episode.show.runtime];
    [self setSeasonNum:episode.season andEpisodeNum:episode.episode];
    FATraktSeason *season = episode.show.seasons[episode.season.intValue];
    if (season.poster) {
        [self setPosterToURL:season.poster];
    } else {
        [self setPosterToURL:episode.show.images.poster];
    }
}

- (void)showDetailForEpisode:(FATraktEpisode *)episode
{
    _contentType = FASearchScopeEpisodes;
    _currentContent = episode;
    _directorLabel = nil;
    _showNameLabel = self.detailLabel1;
    _runtimeLabel = self.detailLabel4;
    _networkLabel = self.detailLabel3;
    _episodeNumLabel = self.detailLabel2;
    
    self.actionButton.title = @"Check In";
    self.coverImageView.image = _placeholderImage;
    _imageLoaded = NO;
    if (!episode.requestedDetailedInformation) {
        episode.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForEpisode:episode callback:^(FATraktEpisode *episode) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForEpisode:episode];
        }];
    }
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Episode", nil);
    [self loadValuesForEpisode:episode];
}

- (IBAction)actionItem:(id)sender
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;

    if (_contentType == FASearchScopeMovies || _contentType == FASearchScopeEpisodes) {
        // do checkin
    } else {
        // show list of episodes
        FAEpisodeListViewController *eplistViewController = [storyboard instantiateViewControllerWithIdentifier:@"eplist"];
        [self.navigationController pushViewController:eplistViewController animated:YES];
        [eplistViewController showEpisodeListForShow:(FATraktShow *)_currentContent];
    }
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
