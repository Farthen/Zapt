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
#import "UIView+FrameAdditions.h"
#import "NSObject+PerformBlock.h"
#import "UIView+Animations.h"
#import "FATitleLabel.h"
#import "FAScrollViewWithTopView.h"

#import "FASearchViewController.h"
#import "FAEpisodeListViewController.h"

#import "FAProgressHUD.h"
#import "FAContentPrefsView.h"
#import "FAProgressView.h"
#import "FANextUpViewController.h"

#import "FATrakt.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_VIEWCONTROLLER

@interface FADetailViewController () {
    BOOL _showing;
    BOOL _willAppear;
    
    UIViewController *_imageViewController;
    UIViewController *_prefsViewController;
        
    NSLayoutConstraint *_contentViewSizeConstraint;
    
    FATraktContentType _contentType;
    FATraktContent *_currentContent;
    BOOL _loadContent;
    
    BOOL _animatesLayoutChanges;
    
    UIImage *_coverImage;
    CGFloat _imageHeight;
    BOOL _imageLoaded;
    BOOL _imageDisplayed;
    BOOL _willDisplayImage;
    BOOL _displayImageWhenFinishedShowing;
    
    UIImageView *_ratingsView;
    UIImage *_ratingsViewImageLove;
    UIImage *_ratingsViewImageHate;
    
    FAContentPrefsView *_prefsView;
    
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _showing = NO;
    _animatesLayoutChanges = NO;
    self.nextUpHeightConstraint.constant = 0;
    
    // Add constraint for minimal size of scroll view content
    /*_contentViewSizeConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.scrollView addConstraint:_contentViewSizeConstraint];
    [self.contentView updateConstraintsIfNeeded];*/
    
    /*UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Episodes", nil) style:UIBarButtonItemStyleDone target:self action:@selector(actionDoneButton:)];
    self.navigationItem.rightBarButtonItem = btnAction;*/
    self.actionButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Check In", nil), NSLocalizedString(@"Episodes", nil), nil];
    
    if (_loadContent) {
        if (_contentType == FATraktContentTypeMovies) {
            self.navigationItem.title = NSLocalizedString(@"Movie", nil);
            [self displayMovie:(FATraktMovie *)_currentContent];
        } else if (_contentType == FATraktContentTypeShows) {
            self.navigationItem.title = NSLocalizedString(@"Show", nil);
            [self displayShow:(FATraktShow *)_currentContent];
        } else if (_contentType == FATraktContentTypeEpisodes) {
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
    [self.scrollView layoutIfNeeded];
    
    if (_imageLoaded && !_imageDisplayed) {
        [self doDisplayImageAnimated:NO];
    }
    
    _willAppear = YES;
    _animatesLayoutChanges = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DDLogViewController(@"view content size: %f x %f", self.view.frame.size.width, self.view.frame.size.height);
    _showing = YES;
    if (_displayImageWhenFinishedShowing) {
        [self doDisplayImageAnimated:YES];
        _displayImageWhenFinishedShowing = NO;
    }
    [self.contentView layoutIfNeeded];
    [self.scrollView layoutIfNeeded];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.scrollView layoutIfNeeded];
    [self.titleLabel invalidateIntrinsicContentSize];
    [self.titleLabel.superview updateConstraints];
    if (_imageDisplayed) {
        [self doDisplayImageAnimated:NO];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    [self.contentView resizeHeightToFitSubviewsWithMinimumSize:0];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.coverImageView invalidateIntrinsicContentSize];
    //[self.coverImageView updateConstraints];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[self.scrollView hideBackView:NO];
    
    // fix stupid bug http://stackoverflow.com/questions/12580434/uiscrollview-autolayout-issue
    //_showing = NO;
    //self.scrollView.contentOffset = CGPointZero;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.overviewLabel sizeToFit];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

- (void)setUpPrefs
{
    /*if (!self.scrollView.backView) {
        _prefsView = [[FAContentPrefsView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 200)];
        
        self.scrollView.backView = _prefsView;
        self.scrollView.backViewContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"outlets"]];
    }
    [_prefsView displayContent:_currentContent];
    [_prefsView.watchlistAddButton addTarget:self action:@selector(prefsViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [_prefsView.loveSegmentedControl addTarget:self action:@selector(prefsViewAction:) forControlEvents:UIControlEventValueChanged];*/
}


- (void)displayImage
{
    // decide if displaying it animated or not
    BOOL animated;
    if (_willAppear && !_showing) {
        _displayImageWhenFinishedShowing = YES;
        return;
    } else if (_willAppear && _showing && !_imageDisplayed) {
        animated = YES;
    } else {
        animated = NO;
    }
    [self doDisplayImageAnimated:animated];
}

- (void)setNextUpViewWithContent:(FATraktContent *)content
{
    if (content) {
        [UIView animateSynchronizedIf:_animatesLayoutChanges duration:0.3 setUp:^{
            [self.nextUpViewController displayNextUp:content];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.intrinsicHeight;
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)doDisplayImageAnimated:(BOOL)animated
{
    if (!_willDisplayImage) {
        _imageDisplayed = NO;
        _willDisplayImage = YES;
        _showing = YES;
        
        CGFloat firstOffset = -(self.imageViewToTopLayoutConstraint.constant + self.coverImageView.intrinsicContentSize.height + self.titleLabel.frameHeight);
        CGFloat newImageViewToTopLayoutConstraint = - self.coverImageView.intrinsicContentSize.height + self.titleLabel.frameHeight;
        CGFloat secondOffset = - self.imageViewToTopLayoutConstraint.constant;
        
        CGFloat timeFactor = firstOffset / (firstOffset + secondOffset);
        CGFloat totalDuration = 0.5;
        CGFloat firstDuration = timeFactor * totalDuration;
        CGFloat secondDuration = totalDuration - firstDuration;
        
        [UIView animateSynchronizedIf:animated duration:firstDuration delay:0 options:UIViewAnimationOptionCurveEaseIn setUp:^{
            self.coverImageView.image = _coverImage;
            
            CGFloat topSpaceHeight = [self.scrollView convertPoint:CGPointMake(0, 0) toView:nil].y;
            if (!self.coverImageViewHeightConstraint) {
                self.coverImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.coverImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.coverImageView.intrinsicContentSize.height];
                [self.coverImageView addConstraint:self.coverImageViewHeightConstraint];
            } else {
                self.coverImageViewHeightConstraint.constant = self.coverImageView.intrinsicContentSize.height;
                [self.coverImageView setNeedsUpdateConstraints];
            }
            self.imageViewToTopLayoutConstraint.constant = - self.coverImageView.intrinsicContentSize.height - topSpaceHeight;
            [self.scrollView layoutIfNeeded];
            
            self.imageViewToTopLayoutConstraint.constant = newImageViewToTopLayoutConstraint;
            self.imageViewToBottomViewLayoutConstraint.constant = - self.titleLabel.intrinsicContentSize.height;
            self.view.userInteractionEnabled = NO;
        } animations:^{
            [self.scrollView layoutIfNeeded];
        } completion:nil];
        [UIView animateSynchronizedIf:animated duration:secondDuration delay:0 options:UIViewAnimationOptionCurveEaseOut setUp:^{
            self.imageViewToTopLayoutConstraint.constant = 0;
        } animations:^{
            [self.scrollView layoutIfNeeded];
        } completion:^(BOOL finished){
            self.view.userInteractionEnabled = YES;
            _imageDisplayed = YES;
            _willDisplayImage = NO;
        }];
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
                DDLogViewController(@"Not displaying image of item %@ because an error occured", _currentContent);
                _imageLoaded = NO;
            }];
        } else {
            _imageLoaded = YES;
            [self displayImage];
        }
    }
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel invalidateIntrinsicContentSize];
}

- (void)setOverview:(NSString *)overview
{
    self.overviewLabel.text = overview;
    //self.overviewLabel.text = @"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat.";
}

- (void)setProgress:(FATraktShowProgress *)progress
{
    if (progress) {
        [UIView animateSynchronizedIf:_animatesLayoutChanges duration:0.3 setUp:^{
            [self.nextUpViewController displayProgress:progress];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.intrinsicHeight;
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)loadValueForContent:(FATraktContent *)item
{
    [self setUpPrefs];
    self.title = item.title;
    [self setOverview:item.overview];
    if (_contentType != FATraktContentTypeEpisodes) {
        [self setPosterToURL:_currentContent.images.fanart];
    } else {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        if (episode.images.screen) {
            [self setPosterToURL:episode.images.screen];
        } else {
            [self setPosterToURL:episode.show.images.fanart];
        }
    }
    [self.overviewLabel sizeToFit];
    
    /*if (!_ratingsView) {
        _ratingsViewImageLove = [UIImage imageNamed:@"badge-love"];
        _ratingsViewImageHate = [UIImage imageNamed:@"badge-hate"];
        _ratingsView = [[UIImageView alloc] initWithImage:_ratingsViewImageLove];
        CGFloat imageWidth = 26;
        CGFloat imageHeight = 25.5;
        CGFloat x = self.scrollViewBackgroundView.frame.size.width - imageWidth;
        CGRect imageFrame = CGRectMake(x, 0, imageWidth, imageHeight);
        _ratingsView.frame = imageFrame;
        [self.scrollViewBackgroundView addSubview:_ratingsView];
        //self.scrollView.hoverView = self.scrollViewBackgroundView;
    }
    
    if ([item.rating isEqualToString:FATraktRatingLove]) {
        _ratingsView.image = _ratingsViewImageLove;
        _ratingsView.hidden = NO;
    } else if ([item.rating isEqualToString:FATraktRatingHate]) {
        _ratingsView.image = _ratingsViewImageHate;
        _ratingsView.hidden = NO;
    } else {
        _ratingsView.hidden = YES;
    }*/
}

- (void)loadValuesForMovie:(FATraktMovie *)movie
{
    [self loadValueForContent:movie];
}

- (void)displayMovie:(FATraktMovie *)movie
{
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    
    [self loadValuesForMovie:movie];
    
    [[FATrakt sharedInstance] detailsForMovie:movie callback:^(FATraktMovie *movie) {
        [self loadValuesForMovie:movie];
        _currentContent = movie;
    }];
}

- (void)loadValuesForShow:(FATraktShow *)show
{
    [self loadValueForContent:show];
    [self setProgress:show.progress];
    [self setNextUpViewWithContent:show.progress.next_episode];
    
    [self.view layoutIfNeeded];
    [self.view updateConstraintsIfNeeded];
}

- (void)displayShow:(FATraktShow *)show
{
    DDLogViewController(@"Displaying show %@", show.description);
    self.actionButton.title = NSLocalizedString(@"Episodes", nil);
    [[FATrakt sharedInstance] detailsForShow:show callback:^(FATraktShow *show) {
        [self loadValuesForShow:show];
    }];
    [[FATrakt sharedInstance] progressForShow:show callback:^(FATraktShowProgress *progress){
        [self loadValuesForShow:show];
    }];
    [self loadValuesForShow:show];
}

- (void)loadValuesForEpisode:(FATraktEpisode *)episode
{
    [self loadValueForContent:episode];
    //FATraktSeason *season = episode.show.seasons[episode.season.unsignedIntValue];
    [self.view layoutIfNeeded];
}

- (void)displayEpisode:(FATraktEpisode *)episode
{
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    [[FATrakt sharedInstance] detailsForEpisode:episode callback:^(FATraktEpisode *episode) {
        [self loadValuesForEpisode:episode];
    }];
    [self loadValuesForEpisode:episode];
}

- (void)loadContent:(FATraktContent *)content
{
    _currentContent = content;
    _contentType = content.contentType;
    
    if (_willAppear) {
        if (content.contentType == FATraktContentTypeMovies) {
            return [self displayMovie:(FATraktMovie *)content];
        } else if (content.contentType == FATraktContentTypeShows) {
            return [self displayShow:(FATraktShow *)content];
        } else if (content.contentType == FATraktContentTypeEpisodes) {
            return [self displayEpisode:(FATraktEpisode *)content];
        }
    } else {
        _loadContent = YES;
    }
}

#pragma mark IBActions
- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionItem:(id)sender
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;

    if (_contentType == FATraktContentTypeMovies || _contentType == FATraktContentTypeEpisodes) {
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


#pragma mark UIActionSheet
- (void)prefsViewAction:(id)sender
{
    FAProgressHUD *hud = [[FAProgressHUD alloc] initWithView:self.view];
    hud.disabledUIElements = @[self.tabBarController.tabBar, self.view];
    if (sender == _prefsView.watchlistAddButton) {
        if (_currentContent.in_watchlist) {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Removing from watchlist", nil)];
            [[FATrakt sharedInstance] removeFromWatchlist:_currentContent callback:^(void) {
                [hud showProgressHUDSuccess];
                _currentContent.in_watchlist = NO;
                [self setUpPrefs];
            } onError:^(LRRestyResponse *response) {
                [hud showProgressHUDFailed];
            }];
        } else {
            [hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding to watchlist", nil)];
            [[FATrakt sharedInstance] addToWatchlist:_currentContent callback:^(void) {
                [hud showProgressHUDSuccess];
                _currentContent.in_watchlist = YES;
                [self setUpPrefs];
            } onError:^(LRRestyResponse *response) {
                [hud showProgressHUDFailed];
            }];
        }
    } else if (sender == _prefsView.loveSegmentedControl) {
        NSInteger selectedSegment = _prefsView.loveSegmentedControl.selectedSegmentIndex;
        DDLogViewController(@"Selected Rating segment: %i", selectedSegment);
        NSString *newRating = FATraktRatingNone;
        if (selectedSegment == 0) {
            if (![_currentContent.rating isEqualToString:FATraktRatingLove]) {
                newRating = FATraktRatingLove;
            } else {
                newRating = FATraktRatingNone;
            }
        } else if (selectedSegment == 1) {
            if (![_currentContent.rating isEqualToString:FATraktRatingHate]) {
                newRating = FATraktRatingHate;
            } else {
                newRating = FATraktRatingNone;
            }
        }
        [hud showProgressHUDSpinnerWithText:@"Rating"];
        [[FATrakt sharedInstance] rate:_currentContent love:newRating callback:^{
            _currentContent.rating = newRating;
            [hud showProgressHUDSuccess];
            [self loadContent:_currentContent];
            [_prefsView displayContent:_currentContent];
        } onError:^(LRRestyResponse *response){
            [hud showProgressHUDFailed];
            [_prefsView displayContent:_currentContent];
        }];
    }
}

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
