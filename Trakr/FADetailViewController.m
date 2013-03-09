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

#import "FADetailImageViewController.h"
#import "FASearchViewController.h"
#import "FAStatusBarSpinnerController.h"
#import "UIView+SizeToFitSubviews.h"
#import "NSObject+PerformBlock.h"
#import "FATitleLabel.h"
#import "FAScrollViewWithTopView.h"

#import "FASearchViewController.h"
#import "FAEpisodeListViewController.h"

#import "FAProgressHUD.h"
#import "FAContentPrefsView.h"

#import "FATrakt.h"

@interface FADetailViewController () {
    BOOL _showing;
    BOOL _willAppear;
    
    UIViewController *_imageViewController;
    UIViewController *_prefsViewController;
    
    UIImageView *_ratingsView;
    
    NSLayoutConstraint *_contentViewSizeConstraint;
    UIActionSheet *_actionSheetAdd;
    UIActionSheet *_actionSheetRemove;
    
    FAContentType _contentType;
    FATraktContent *_currentContent;
    BOOL _loadContent;
    
    UIImage *_placeholderImage;
    UIImage *_coverImage;
    CGFloat _imageHeight;
    BOOL _imageLoaded;
    BOOL _imageLoading;
    BOOL _imageDisplayed;
    BOOL _willDisplayImage;
    BOOL _displayImageWhenFinishedShowing;
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
    [super awakeFromNib];
    //_placeholderImage = self.coverImageView.image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _showing = NO;
        
    // Add constraint for minimal size of scroll view content
    /*_contentViewSizeConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:_contentViewSizeConstraint];
    [self.contentView updateConstraintsIfNeeded];*/
    
    UIBarButtonItem *btnShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItem:)];
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Check In", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionItem:)];
    self.actionButton = btnAction;
    btnAction.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Check In", nil), NSLocalizedString(@"Episodes", nil), nil];
    [self.navigationItem setRightBarButtonItems:@[btnAction, btnShare] animated:NO];
    
    _actionSheetAdd = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add to watchlist", nil), /*NSLocalizedString(@"Add to list …", nil),*/ nil];
    _actionSheetRemove = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Remove from watchlist", nil), /*NSLocalizedString(@"Add to list …", nil),*/ nil];
    
    if (_loadContent) {
        if (_contentType == FAContentTypeMovies) {
            self.navigationItem.title = NSLocalizedString(@"Movie", nil);
            [self displayMovie:(FATraktMovie *)_currentContent];
        } else if (_contentType == FAContentTypeShows) {
            self.navigationItem.title = NSLocalizedString(@"Show", nil);
            [self displayShow:(FATraktShow *)_currentContent];
        } else if (_contentType == FAContentTypeEpisodes) {
            self.navigationItem.title = NSLocalizedString(@"Episode", nil);
            [self displayEpisode:(FATraktEpisode *)_currentContent];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.contentView.frame.size;
    [self.contentView updateConstraintsIfNeeded];
    [self.scrollView layoutSubviews];
    
    _willAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [APLog tiny:@"view content size: %f x %f", self.view.frame.size.width, self.view.frame.size.height];
    _showing = YES;
    if (_displayImageWhenFinishedShowing) {
        [self doDisplayImageAnimated:YES];
        _displayImageWhenFinishedShowing = NO;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    [self.contentView resizeHeightToFitSubviewsWithMinimumSize:0];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // fix stupid bug http://stackoverflow.com/questions/12580434/uiscrollview-autolayout-issue
    //_showing = NO;
    //self.scrollView.contentOffset = CGPointZero;
}

- (void)displayPageControl:(BOOL)animated
{
    FAContentPrefsView *contentPrefsview = [[FAContentPrefsView alloc] initWithFrame:self.coverImageView.frame];
    [contentPrefsview displayContent:_currentContent];
        
    self.pageControl = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageControl.dataSource = self;
}

- (void)displayImage
{
    // decide if displaying it animated or not
    BOOL animated;
    if (_willAppear && !_showing) {
        _displayImageWhenFinishedShowing = YES;
        return;
    } else if (_willAppear && _showing) {
        animated = YES;
    } else {
        animated = NO;
    }
    [self doDisplayImageAnimated:animated];
}

- (void)doDisplayImageAnimated:(BOOL)animated
{
    if (!_willDisplayImage) {
        _imageDisplayed = NO;
        _willDisplayImage = YES;
        _showing = YES;
        self.coverImageView.image = _coverImage;
        CGFloat originalImageWidth = _coverImage.size.width;
        if (originalImageWidth == 0) {
            [APLog error:@"Wanting to set an image with zero width - this is not possible"];
            return;
        }
        CGFloat titleHeight;
        if (self.titleLabel.frame.size.height != 0) {
            titleHeight = self.titleLabel.frame.size.height;
        } else {
            titleHeight = 27;
        }
        self.scrollView.topViewAnimationStyle = FAScrollViewWithTopViewAnimationStyleNone;
        [self.scrollView presentTopView:self.coverImageView withBackgroundView:self.titleBackgroundView overlapping:titleHeight animated:animated];
    }
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""]/* && ![posterURL isEqualToString:@"http://trakt.us/images/fanart-summary.jpg"]*/) {
        if (!_imageLoaded) {
            [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:940 callback:^(UIImage *image) {
                _imageLoaded = YES;
                _coverImage = image;
                [self displayImage];
            } onError:^(LRRestyResponse *response) {
                [APLog error:@"Not displaying image of item %@ because an error occured", _currentContent];
                _imageLoaded = NO;
            }];
        } else {
            [self displayImage];
        }
    }
}

- (void)setReleaseDate:(NSDate *)date withCaption:(NSString *)caption
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ %@", nil), caption, dateString]];
    [labelString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, caption.length)];
    [labelString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, caption.length)];
    
    
    _releaseDateLabel.attributedText = labelString;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel invalidateIntrinsicContentSize];
}

- (void)setDirectors:(NSArray *)directors
{
    NSMutableString *directorString = [[NSMutableString alloc] init];
    for (FATraktPeople *people in directors) {
        if ([directorString isEqualToString:@""]) {
            [directorString appendString:people.name];
        } else {
            [directorString appendFormat:NSLocalizedString(@", %@", nil), people.name];
        }
    }
    NSAttributedString *directorString_ = [[NSAttributedString alloc] initWithString:directorString];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:directorString];
    if ([directorString isEqualToString:@""]) {
        directorString_ = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"unknown", nil) attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:14]}];
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Directors ", nil)]];
        [text appendAttributedString:directorString_];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 9)];
        [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 9)];
    } else {
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, directorString.length)];
        [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, directorString.length)];
    }
    _directorLabel.attributedText = text;
}

- (void)setRuntime:(NSNumber *)runtime
{
    NSAttributedString *runtime_;
    if (!runtime || runtime.intValue == 0) {
        runtime_ = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"unknown", nil) attributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
    } else {
        runtime_ = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@ min", nil), [runtime stringValue]]];
    }
    NSMutableAttributedString *runtimeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Runtime ", nil)]];
    [runtimeString appendAttributedString:runtime_];
    [runtimeString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 7)];
    [runtimeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 7)];
    _runtimeLabel.attributedText = runtimeString;
}

- (void)setOverview:(NSString *)overview
{
    self.overviewLabel.text = overview;
}

- (void)setTagline:(NSString *)tagline
{
    _taglineLabel.text = tagline;
}

- (void)setNetwork:(NSString *)network
{
    NSAttributedString *network_;
    if (!network) {
        network_ = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"unknown", nil) attributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
    } else {
        network_ = [[NSAttributedString alloc] initWithString:network];
    }
    NSMutableAttributedString *networkString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Network ", nil)];
    [networkString appendAttributedString:network_];
    [networkString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 7)];
    [networkString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 7)];
    
    _networkLabel.attributedText = networkString;
}

- (void)setSeasonNum:(NSNumber *)season andEpisodeNum:(NSNumber *)episode
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), season.intValue, episode.intValue]];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 6)];
    [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 6)];
    
    _episodeNumLabel.attributedText = text;
}

- (void)setShowName:(NSString *)showName
{
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:showName];
    [name addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, showName.length)];
    [name addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, showName.length)];

    _showNameLabel.attributedText = name;
}

- (void)setAirDay:(NSString *)day andTime:(NSString *)time
{
    NSAttributedString *time_;
    if (!day || !time) {
        time_ = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"unknown", nil) attributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:14]}];
    } else {
        time_ = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ at %@", day, time]];
    }
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Airs ", nil)];
    [title appendAttributedString:time_];
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 4)];
    [title addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(0, 4)];

    _airTimeLabel.attributedText = title;
}

- (void)loadValueForContent:(FATraktContent *)item
{
    self.title = item.title;
    [self setOverview:item.overview];
    if (_contentType != FAContentTypeEpisodes) {
        [self setPosterToURL:_currentContent.images.fanart];
    } else {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        if (episode.images.screen) {
            NSLog(@"Setting poster to url: %@", episode.images.screen);
            [self setPosterToURL:episode.images.screen];
        } else {
            [self setPosterToURL:episode.show.images.fanart];
        }
    }
    [self.overviewLabel sizeToFit];
    
    if ([item.rating isEqualToString:@"love"]) {
        if (!_ratingsView) {
            _ratingsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge-love"]];
            CGFloat imageWidth = 26;
            CGFloat imageHeight = 25.5;
            CGFloat x = self.scrollViewBackgroundView.frame.size.width - imageWidth;
            CGRect imageFrame = CGRectMake(x, 0, imageWidth, imageHeight);
            _ratingsView.frame = imageFrame;
            [self.scrollViewBackgroundView addSubview:_ratingsView];
            self.scrollView.hoverView = self.scrollViewBackgroundView;
        }
        _ratingsView.hidden = NO;
    } else {
        _ratingsView.hidden = YES;
    }
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
    [self setReleaseDate:movie.released withCaption:NSLocalizedString(@"Released", nil)];
    [self setTagline:movie.tagline];
    
    //[self viewDidLayoutSubviews];
    [self.view layoutSubviews];
}

- (void)displayMovie:(FATraktMovie *)movie
{
    _directorLabel = self.detailLabel1;
    _runtimeLabel = self.detailLabel2;
    _releaseDateLabel = self.detailLabel3;
    
    // FIXME some other value for 4th label
    self.detailLabel4.text = @"";
    _taglineLabel = nil;
    _networkLabel = nil;
    
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    self.coverImageView.image = _placeholderImage;
    
    [self loadValuesForMovie:movie];
    
    if (!movie.requestedDetailedInformation) {
        movie.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] movieDetailsForMovie:movie callback:^(FATraktMovie *movie) {
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            movie.loadedDetailedInformation = YES;
            [self loadValuesForMovie:movie];
            _currentContent = movie;
        }];
    }
}

- (void)loadValuesForShow:(FATraktShow *)show
{
    [self loadValueForContent:show];
    [self loadValueForWatchableBaseItem:show];
    [self setNetwork:show.network];
    [self setReleaseDate:show.first_aired withCaption:NSLocalizedString(@"First Aired", nil)];
    [self setAirDay:show.air_day andTime:show.air_time];
    
    [self.view layoutSubviews];
    [self.view updateConstraintsIfNeeded];
}

- (void)displayShow:(FATraktShow *)show
{
    _directorLabel = nil;
    
    _runtimeLabel = self.detailLabel2;
    _networkLabel = self.detailLabel1;
    _releaseDateLabel = self.detailLabel3;
    _airTimeLabel = self.detailLabel4;
    
    self.actionButton.title = NSLocalizedString(@"Episodes", nil);
    self.coverImageView.image = _placeholderImage;
    if (!show.requestedDetailedInformation) {
        show.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForShow:show callback:^(FATraktShow *show) {
            show.loadedDetailedInformation = YES;
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
    [self.view layoutSubviews];
}

- (void)displayEpisode:(FATraktEpisode *)episode
{
    _directorLabel = nil;
    _showNameLabel = self.detailLabel3;
    _runtimeLabel = self.detailLabel4;
    _networkLabel = self.detailLabel1;
    _episodeNumLabel = self.detailLabel2;
    
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    self.coverImageView.image = _placeholderImage;
    if (!episode.requestedDetailedInformation) {
        episode.requestedDetailedInformation = YES;
        [[FAStatusBarSpinnerController sharedInstance] startActivity];
        [[FATrakt sharedInstance] showDetailsForEpisode:episode callback:^(FATraktEpisode *episode) {
            episode.loadedDetailedInformation = YES;
            [[FAStatusBarSpinnerController sharedInstance] finishActivity];
            [self loadValuesForEpisode:episode];
        }];
    }
    [self loadValuesForEpisode:episode];
}


- (void)loadContent:(FATraktContent *)content
{
    _currentContent = content;
    _contentType = content.contentType;
    
    if (_willAppear) {
        if (content.contentType == FAContentTypeMovies) {
            return [self displayMovie:(FATraktMovie *)content];
        } else if (content.contentType == FAContentTypeShows) {
            return [self displayShow:(FATraktShow *)content];
        } else if (content.contentType == FAContentTypeEpisodes) {
            return [self displayEpisode:(FATraktEpisode *)content];
        }
    } else {
        _loadContent = YES;
    }
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

    if (_contentType == FAContentTypeMovies || _contentType == FAContentTypeEpisodes) {
        // do checkin
        UIBarButtonItem *button = sender;
        button.enabled = NO;
        
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Checking In…", nil)];
        [hud hideProgressHUD];
        button.enabled = YES;
    } else {
        // show list of episodes
        FAEpisodeListViewController *eplistViewController = [storyboard instantiateViewControllerWithIdentifier:@"eplist"];
        [self.navigationController pushViewController:eplistViewController animated:YES];
        [eplistViewController showEpisodeListForShow:(FATraktShow *)_currentContent];
    }
}

- (IBAction)shareItem:(id)sender
{
    if (_currentContent.in_watchlist) {
        [_actionSheetRemove showFromTabBar:self.tabBarController.tabBar];
    } else {
        [_actionSheetAdd showFromTabBar:self.tabBarController.tabBar];
    }
}

- (IBAction)touchedCover:(id)sender
{
    _photos = [[NSMutableArray alloc] init];
    FATraktImageList *imageList;
    
    FATraktShow *show = nil;
    if (_contentType == FAContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        show = episode.show;
    } else if (_contentType == FAContentTypeShows) {
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

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
        hud.disabledUIElements = @[self.tabBarController.tabBar, self.view];
        if (_currentContent.in_watchlist) {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
            [[FATrakt sharedInstance] removeFromWatchlist:_currentContent callback:^(void) {
                [hud showProgressHUDSuccess];
                _currentContent.in_watchlist = NO;
            } onError:^(LRRestyResponse *response) {
                [hud showProgressHUDFailed];
            }];
        } else if (!_currentContent.in_watchlist) {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to watchlist", nil)];
            [[FATrakt sharedInstance] addToWatchlist:_currentContent callback:^(void) {
                [hud showProgressHUDSuccess];
                _currentContent.in_watchlist = YES;
            } onError:^(LRRestyResponse *response) {
                [hud showProgressHUDFailed];
            }];
        }
    }
}

#pragma mark UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
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
