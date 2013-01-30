//
//  FADetailViewController.m
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FADetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#import "FASearchViewController.h"
#import "FAStatusBarSpinnerController.h"
#import "UIView+SizeToFitSubviews.h"
#import "FATitleLabel.h"

#import "FASearchViewController.h"
#import "FAEpisodeListViewController.h"

#import <MBProgressHUD.h>

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
    BOOL _showing;
    
    NSLayoutConstraint *_contentViewSizeConstraint;
    
    FASearchScope _contentType;
    FATraktContentType *_currentContent;
    UIImage *_placeholderImage;
    BOOL _imageLoaded;
    BOOL _imageDisplayed;
    UILabel *_networkLabel;
    UILabel *_episodeNumLabel;
    UILabel *_runtimeLabel;
    UILabel *_directorLabel;
    UILabel *_taglineLabel;
    UILabel *_releaseDateLabel;
    UILabel *_showNameLabel;
    UILabel *_airTimeLabel;
    
    NSMutableArray *_photos;
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
    _showing = NO;
    
    // Add constraint for minimal size of scroll view content
    _contentViewSizeConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:_contentViewSizeConstraint];
    [self.contentView updateConstraintsIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = self.contentView.frame.size;
    [self setPosterToURL:_currentContent.images.fanart];
    [self.contentView updateConstraintsIfNeeded];
    [APLog tiny:@"view content size: %f x %f", self.view.frame.size.width, self.view.frame.size.height];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    [self.contentView updateConstraintsIfNeeded];
    self.scrollView.contentSize = self.contentView.frame.size;
    
    if (_imageDisplayed && !_showing) {
        _showing = YES;
        CGRect finalFrame = CGRectMake(0, 0, 320, 180);
        CGFloat top = finalFrame.size.height - self.titleLabel.frame.size.height;
        self.scrollView.contentOffset = CGPointMake(0, -top);
    }
    
    CGRect imageViewFrame = CGRectMake(0, 0, 320, 180);
    self.coverImageView.frame = imageViewFrame;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // fix stupid bug http://stackoverflow.com/questions/12580434/uiscrollview-autolayout-issue
    _showing = NO;
    self.scrollView.contentOffset = CGPointZero;
}

- (void)setReleaseDate:(NSDate *)date withCaption:(NSString *)caption
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", caption, dateString]];
    [labelString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, caption.length)];
    [labelString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, caption.length)];

    
    _releaseDateLabel.attributedText = labelString;
    [_releaseDateLabel sizeToFit];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel invalidateIntrinsicContentSize];
    //[self.titleLabel sizeToFit];
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
    NSMutableAttributedString *runtimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Runtime %@ min", [runtime stringValue]]];
    [runtimeString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 7)];
    [runtimeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 7)];
    _runtimeLabel.attributedText = runtimeString;
    [_runtimeLabel sizeToFit];
}

- (void)displayImage
{
    if (!_imageDisplayed) {
        _imageDisplayed = YES;
        CGRect newFrame = CGRectMake(0, 0, 320, 0);
        self.coverImageView.frame = newFrame;
        CGRect finalFrame = CGRectMake(0, 0, 320, 180);
        CGFloat top = finalFrame.size.height - self.titleLabel.frame.size.height;
        CGFloat initialOffset = self.scrollView.contentOffset.y;
        [UIView animateWithDuration:0.3 animations:^(void) {
            self.scrollView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
            self.scrollView.contentOffset = CGPointMake(0, initialOffset - top);
            self.coverImageView.frame = finalFrame;
        }];
    }
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""]) {
        if (!_imageLoaded) {
            _imageLoaded = YES;
            [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:940 callback:^(UIImage *image) {
                self.coverImageView.image = image;
                [self displayImage];
            }];
        } else {
            [self displayImage];
        }
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
    NSMutableAttributedString *networkString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Network %@", network]];
    [networkString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 7)];
    [networkString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 7)];

    _networkLabel.attributedText = networkString;
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
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Airs %@ at %@", day, time]];
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 4)];
    [title addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 4)];

    _airTimeLabel.attributedText = title;
    //[_airTimeLabel sizeToFit];
}

- (void)loadValueForContent:(FATraktContentType *)item
{
    self.title = item.title;
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
    [self setReleaseDate:movie.released withCaption:@"Released"];
    [self setTagline:movie.tagline];
    
    //[self viewDidLayoutSubviews];
    [self.view layoutSubviews];
}

- (void)showDetailForMovie:(FATraktMovie *)movie
{
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Movie", nil);
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
    _imageDisplayed = NO;
    if (!movie.requestedDetailedInformation) {
        movie.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] movieDetailsForMovie:movie callback:^(FATraktMovie *movie) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForMovie:movie];
        }];
    }
    [self loadValuesForMovie:movie];
}

- (void)loadValuesForShow:(FATraktShow *)show
{
    [self loadValueForContent:show];
    [self loadValueForWatchableBaseItem:show];
    [self setNetwork:show.network];
    [self setReleaseDate:show.first_aired withCaption:@"First Aired"];
    [self setAirDay:show.air_day andTime:show.air_time];
    
    [self.view layoutSubviews];
    [self.view updateConstraintsIfNeeded];
}

- (void)showDetailForShow:(FATraktShow *)show
{
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Show", nil);
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
    _imageDisplayed = NO;
    if (!show.requestedDetailedInformation) {
        show.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
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
    [self setShowName:episode.show.title];
    [self setNetwork:episode.show.network];
    [self setRuntime:episode.show.runtime];
    [self setSeasonNum:episode.season andEpisodeNum:episode.episode];
    FATraktSeason *season = episode.show.seasons[episode.season.intValue];
    if (season.poster) {
        //[self setPosterToURL:season.poster];
    } else {
        //[self setPosterToURL:episode.show.images.poster];
    }
    
    [self.view layoutSubviews];
}

- (void)showDetailForEpisode:(FATraktEpisode *)episode
{
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Episode", nil);
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
    _imageDisplayed = NO;
    if (!episode.requestedDetailedInformation) {
        episode.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForEpisode:episode callback:^(FATraktEpisode *episode) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForEpisode:episode];
        }];
    }
    [self loadValuesForEpisode:episode];
}

#pragma mark MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    NSString *photoURLString = _photos[index];
    return [MWPhoto photoWithURL:[NSURL URLWithString:photoURLString]];
}

#pragma mark IBActions
- (IBAction)actionItem:(id)sender
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;

    if (_contentType == FASearchScopeMovies || _contentType == FASearchScopeEpisodes) {
        // do checkin
        UIBarButtonItem *button = sender;
        button.enabled = NO;
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelText = @"Checking in…";
        [hud show:YES];
        [hud hide:YES afterDelay:10];
    } else {
        // show list of episodes
        FAEpisodeListViewController *eplistViewController = [storyboard instantiateViewControllerWithIdentifier:@"eplist"];
        [self.navigationController pushViewController:eplistViewController animated:YES];
        [eplistViewController showEpisodeListForShow:(FATraktShow *)_currentContent];
    }
}

- (IBAction)touchedCover:(id)sender
{
    _photos = [[NSMutableArray alloc] init];
    FATraktImageList *imageList;
    
    FATraktShow *show = nil;
    if (_contentType == FASearchScopeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        show = episode.show;
    } else if (_contentType == FASearchScopeShows) {
        show = (FATraktShow *)_currentContent;
    }
    // TODO: load season information
    if (show) {
        imageList = show.images;
        NSArray *seasons = show.seasons;
        for (int i = 1; i < seasons.count; i++) {
            FATraktSeason *season = seasons[i];
            if (season.poster) {
                [_photos addObject:season.poster];
            }
        }
    } else {
        imageList = _currentContent.images;
    }
    if (imageList.poster) {
        [_photos addObject:imageList.poster];
    }
    if (imageList.fanart) {
        [_photos addObject:imageList.fanart];
    }
    if (imageList.banner) {
        [_photos addObject:imageList.banner];
    }
    
    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:0]; // Example: allows second image to be presented first
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y + scrollView.contentInset.top;
    CGRect frame = self.coverImageView.frame;
    //CGRect newFrame = CGRectMake(frame.origin.x, MIN(-offset, 0), frame.size.width, MAX(180, 180 - offset));
    
    CGFloat scale = (MAX(180, 180 - offset) / 180);
    CGFloat width = 320 * scale;
    CGFloat x = (320 - width) / 2;
    
    CGRect newFrame = CGRectMake(x, MIN(-offset, 0), width, MAX(180, 180 - offset));
    
    // zoom the image view
    [APLog tiny:@"zooming image with scale: %f", scale];
    /*if (_imageDisplayed) {
        CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
        self.coverImageView.transform = transform;
    }*/
    [APLog tiny:@"setting frame to: %fx%f size: %fx%f", newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height];
    self.coverImageView.frame = newFrame;
    [self.coverImageView layoutSubviews];
    [self.view layoutSubviews];
}

#pragma mark misc

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

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

@end
