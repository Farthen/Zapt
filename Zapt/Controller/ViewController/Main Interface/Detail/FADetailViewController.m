//
//  FADetailViewController.m
//  Zapt
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktActivityItemSource.h"
#import "FADetailViewController.h"
#import "FANavigationController.h"

#import <CoreText/CoreText.h>

#import "FASeasonListViewController.h"
#import "FAEpisodeListViewController.h"
#import "FANextUpViewController.h"
#import "FAContentBookmarkViewController.h"
#import "FARatingsViewController.h"
#import "FACheckinViewController.h"

#import <FATrakt/FATrakt.h>
#import <TUSafariActivity/TUSafariActivity.h>

#import "FAGlobalEventHandler.h"
#import "FANotificationScrollViewDelegate.h"

#import "FATitleLabel.h"
#import "FAProgressHUD.h"
#import "FABadges.h"
#import "FAPullScrollViewAccessoryView.h"

#import "FACalendarEventController.h"

#import <NSDate-Extensions/NSDate-Utilities.h>

@interface FADetailViewController () {
    BOOL _showing;
    BOOL _willAppear;
    BOOL _didLoad;
    
    BOOL _willRestoreState;
    
    FATraktContent *_currentContent;
    FATraktAccountSettings *_accountSettings;
    
    BOOL _loadContent;
    BOOL _alreadyBeenShown;
    
    BOOL _animatesLayoutChanges;
    
    UIImage *_coverImage;
    
    BOOL _imageLoaded;
    
    NSString *_imageURL;
    
    BOOL _imageDisplayed;
    BOOL _willDisplayImage;
    BOOL _displayImageWhenFinishedShowing;
    
    BOOL _animatedOverviewText;
    
    BOOL _addedNextEpisodeIndicators;
    
    UITapGestureRecognizer *_detailLabelTapGestureRecognizer;
    UIActivityViewController *_activityViewController;
    
    CGFloat _contentOffsetAfterLayout;
    
    BOOL _loadingEpisodeCounts;
    FAPullScrollViewAccessoryView *_previousEpisodeAccessory;
    FAPullScrollViewAccessoryView *_nextEpisodeAccessory;
    
    FANotificationScrollViewDelegate *_notificationScrollViewDelegate;
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
    
    if (!_activityViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *activityItems = [FATraktActivityItemSource activityItemSourcesWithContent:_currentContent];
            
            TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
            
            _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[safariActivity]];
            _activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypePostToVimeo];
        });
    }
    
    _showing = NO;
    _animatesLayoutChanges = NO;
    
    self.nextUpHeightConstraint.constant = 0;
    self.detailViewHeightConstraint.constant = 0;
    
    self.actionButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Check In", nil), NSLocalizedString(@"Seasons", nil), nil];
    self.ratingsButton.title = @"";
    
    _didLoad = YES;

    if (_loadContent) {
        [self prepareViewForContent];
    }
}

- (void)prepareViewForContent
{
    _currentContent = [_currentContent cachedVersion];
    
    if (_currentContent.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        self.navigationItem.title = [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES];
    } else {
        self.navigationItem.title = [FAInterfaceStringProvider nameForContentType:_currentContent.contentType withPlural:NO capitalized:YES longVersion:YES];
    }
    
    [self loadContentData:_currentContent];
    
    if (_currentContent.contentType == FATraktContentTypeMovies) {
        [self loadMovieData:(FATraktMovie *)_currentContent];
    } else if (_currentContent.contentType == FATraktContentTypeShows) {
        [self loadShowData:(FATraktShow *)_currentContent];
    } else if (_currentContent.contentType == FATraktContentTypeEpisodes) {
        [self loadEpisodeData:(FATraktEpisode *)_currentContent];
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
    
    if (_willRestoreState) {
         [self displayContent:_currentContent];
         //[self loadContent:_currentContent];
        
        [self prepareViewForContent];
    }
    
    _willAppear = YES;
    _animatesLayoutChanges = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_alreadyBeenShown) {
        [self displayRatingForContent:_currentContent ratingsMode:_accountSettings.viewing.ratings_mode];
        [self loadContent:_currentContent];
    }
    
    _showing = YES;
    
    if (_displayImageWhenFinishedShowing) {
        [self doDisplayImageAnimated:YES];
        _displayImageWhenFinishedShowing = NO;
    }
    
    [self.contentView layoutIfNeeded];
    [self.scrollView layoutIfNeeded];
    _alreadyBeenShown = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Update the container view controller for the nextUp view
    self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
    
    [super viewWillLayoutSubviews];
    [self.scrollView layoutIfNeeded];
    [self.titleLabel invalidateIntrinsicContentSize];
    [self.titleLabel.superview updateConstraints];
    
    if (_imageDisplayed) {
        [self doDisplayImageAnimated:NO];
    }
    
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.titleLabel setNeedsLayout];
    self.imageViewToBottomViewLayoutConstraint.constant = -self.titleLabel.intrinsicContentSize.height;
    
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [self.detailLabel setNeedsLayout];
    self.overviewLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if (!_addedNextEpisodeIndicators && _currentContent.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        
        if ([episode.show hasEpisodeCounts]) {
            _addedNextEpisodeIndicators = YES;
            
            if (!_notificationScrollViewDelegate) {
                _notificationScrollViewDelegate = [[FANotificationScrollViewDelegate alloc] init];
                self.scrollView.delegate = _notificationScrollViewDelegate;
            }
            
            if (episode.nextEpisodeIndexPath) {
                _nextEpisodeAccessory = [[FAPullScrollViewAccessoryView alloc] init];
                [_nextEpisodeAccessory addToScrollView:self.scrollView bottom:YES];
                _nextEpisodeAccessory.textLabel.text = NSLocalizedString(@"Next Episode", nil);
                
                _nextEpisodeAccessory.delegate = self;
            }
            
            if (episode.previousEpisodeIndexPath) {
                _previousEpisodeAccessory = [[FAPullScrollViewAccessoryView alloc] init];
                [_previousEpisodeAccessory addToScrollView:self.scrollView bottom:NO];
                _previousEpisodeAccessory.textLabel.text = NSLocalizedString(@"Previous Episode", nil);
                
                _previousEpisodeAccessory.delegate = self;
            }
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    
    if (_contentOffsetAfterLayout != 0) {
        self.scrollView.contentOffset = CGPointMake(0, _contentOffsetAfterLayout - self.scrollView.contentInset.top);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.coverImageView invalidateIntrinsicContentSize];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // If we disabled this, we will enable it again now
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.scrollView.userInteractionEnabled = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.overviewLabel sizeToFit];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

- (void)preferredContentSizeChanged
{
    // This is called when dynamic type settings are changed
    [self.view invalidateIntrinsicContentSize];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    [self.titleLabel setNeedsLayout];
    [self.detailLabel setNeedsLayout];
    
    [self.nextUpViewController preferredContentSizeChanged];
}

- (void)displayImage
{
    // decide if displaying it animated or not
    BOOL animated;
    
    if (_willAppear && !_showing) {
        _displayImageWhenFinishedShowing = YES;
        
        return;
    } else if (_willAppear && _showing && !_imageDisplayed && _animatesLayoutChanges) {
        animated = YES;
    } else if (_imageDisplayed) {
        // Refresh image
        animated = YES;
    } else {
        animated = NO;
    }
    
    [self doDisplayImageAnimated:animated];
}

- (void)setNextUpViewWithEpisode:(FATraktEpisode *)episode
{
    if (episode && ![episode.title isEqualToString:@"TBA"]) {
        BOOL animate = !self.nextUpViewController.displaysNextUp && _animatesLayoutChanges;
        
        [UIView animateSynchronizedIf:animate duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut setUp:^{
            [self.nextUpViewController displayNextUp:episode];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
        } animations:^{
            [self.scrollView layoutIfNeeded];
            [self.contentView layoutIfNeeded];
        } completion:nil];
    } else {
        BOOL animate = self.nextUpViewController.displaysNextUp && _animatesLayoutChanges;
        
        [UIView animateSynchronizedIf:animate duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut setUp:^{
            [self.nextUpViewController hideNextUp];
            [self.contentView recursiveSetNeedsUpdateConstraints];
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)doDisplayImageAnimated:(BOOL)animated
{
    if (!_willDisplayImage) {
        // Scale the image first to screen dimensions
        
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGFloat newWidth = self.coverImageView.frame.size.width;
        CGFloat oldWidth = _coverImage.size.width;
        
        CGFloat ratio = (newWidth / oldWidth) * scale;
        
        CGSize newSize = CGSizeMake(newWidth * scale, ceilf(_coverImage.size.height * ratio));
        UIImage *scaledImage = [_coverImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
        
        
        self.coverImageViewHeightConstraint.constant = scaledImage.size.height / scale;
        [_coverImageView setNeedsUpdateConstraints];
        [_coverImageView setNeedsLayout];
        
        if (animated) {
            _willDisplayImage = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [UIView transitionWithView:self.coverImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.coverImageView.image = scaledImage;
                    _willDisplayImage = NO;
                    _imageDisplayed = YES;
                } completion:nil];
            }];
        } else {
            self.coverImageView.image = scaledImage;
            _imageDisplayed = YES;
            [_coverImageView layoutIfNeeded];
        }
    }
}

- (void)setPosterToURL:(NSString *)posterURL
{
    if (posterURL && ![posterURL isEqualToString:@""] /* && ![posterURL isEqualToString:@"http://trakt.us/images/fanart-summary.jpg"]*/) {
        if (!_imageLoaded || _imageURL != posterURL) {
            _imageURL = posterURL;
            
            [[FATrakt sharedInstance] loadImageFromURL:posterURL withWidth:940 callback:^(UIImage *image) {
                _imageLoaded = YES;
                _coverImage = image;
                [self displayImage];
            } onError:^(FATraktConnectionResponse *connectionError) {
                DDLogViewController(@"Not displaying image of item %@ because an error occured", _currentContent);
                _imageLoaded = NO;
            }];
        } else {
            _imageLoaded = YES;
            [self displayImage];
        }
    }
}

- (void)displayTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel invalidateIntrinsicContentSize];
}

- (void)displayOverview:(NSString *)overview
{
    if (![self.overviewLabel.text isEqualToString:overview]) {
        [UIView animateSynchronizedIf:NO duration:0.0 delay:0 options:UIViewAnimationOptionCurveLinear setUp:^{
            self.overviewLabel.alpha = 0.0;
        } animations:^{
            self.overviewLabel.text = overview;
            [self.overviewLabel setNeedsLayout];
            [self.overviewLabel layoutIfNeeded];
        } completion:nil];
        
        BOOL shouldAnimateOverviewText = !_animatedOverviewText || _animatesLayoutChanges;
        
        [UIView animateSynchronizedIf:shouldAnimateOverviewText duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut setUp:nil animations:^{
            self.overviewLabel.alpha = 1.0;
        } completion:nil];
        
        if (overview) {
            _animatedOverviewText = YES;
        }
    }
}

- (void)displayProgress:(FATraktShowProgress *)progress
{
    if (progress) {
        BOOL animate = !self.nextUpViewController.displaysProgress && _animatesLayoutChanges;
        
        [UIView animateSynchronizedIf:animate duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn setUp:^{
            [self.nextUpViewController displayProgress:progress];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (progress.percentage.unsignedIntegerValue != 100) {
                [self setNextUpViewWithEpisode:progress.next_episode];
            } else {
                [self setNextUpViewWithEpisode:nil];
            }
        }];
    }
}

- (void)displayRatingForContent:(FATraktContent *)content ratingsMode:(FATraktRatingsMode)ratingMode
{
    if (content && [FATraktConnection sharedInstance].usernameAndPasswordValid) {
        self.ratingsButton.enabled = YES;
        
        if (content.rating) {
            self.ratingsButton.enabled = YES;
            
            NSString *ratingString;
            
            if (ratingMode == FATraktRatingsModeAdvanced) {
                ratingString = [FAInterfaceStringProvider nameForRatingScore:content.rating.advancedRating ratingsMode:ratingMode capitalized:YES];
            } else {
                ratingString = [FAInterfaceStringProvider nameForRatingScore:content.rating.simpleRating ratingsMode:ratingMode capitalized:YES];
            }
            
            self.ratingsButton.title = [NSString stringWithFormat:@"Rating: %@", ratingString];
        } else {
            self.ratingsButton.title = [NSString stringWithFormat:NSLocalizedString(@"Rating: Not rated", nil)];
        }
    } else {
        self.ratingsButton.title = nil;
        self.ratingsButton.enabled = NO;
    }
}

- (void)displayGenericContentData:(FATraktContent *)item
{
    if (_accountSettings) {
        [self displayRatingForContent:_currentContent ratingsMode:_accountSettings.viewing.ratings_mode];
    }
    
    [self displayTitle:item.title];
    [self displayOverview:item.overview];
    [self setPosterToURL:item.widescreenImageURL];
    [self.overviewLabel sizeToFit];
    
    if (item.isWatched) {
        [[FABadges instanceForView:self.coverImageView] badge:FABadgeWatched];
    } else {
        [[FABadges instanceForView:self.coverImageView] unbadge:FABadgeWatched];
    }
}

- (void)displayMovie:(FATraktMovie *)movie
{
    [self displayGenericContentData:movie];
}

- (void)displayAccountSettings:(FATraktAccountSettings *)settings
{
    if (_currentContent.rating) {
        [self displayRatingForContent:_currentContent ratingsMode:_accountSettings.viewing.ratings_mode];
    }
}

- (void)loadContentData:(FATraktContent *)content
{
    [[FATrakt sharedInstance] accountSettings:^(FATraktAccountSettings *settings) {
        _accountSettings = settings;
        [self displayAccountSettings:(FATraktAccountSettings *)settings];
    } onError:nil];
}

- (void)loadMovieData:(FATraktMovie *)movie
{
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    
    [self displayMovie:movie];
    
    [[FATrakt sharedInstance] detailsForMovie:movie callback:^(FATraktMovie *movie) {
        [self displayMovie:movie];
        _currentContent = movie;
    } onError:nil];
}

- (void)displayShow:(FATraktShow *)show
{
    [self displayGenericContentData:show];
    [self displayProgress:show.progress];
    
    [self.view layoutIfNeeded];
    [self.view updateConstraintsIfNeeded];
}

- (void)loadShowData:(FATraktShow *)show
{
    DDLogViewController(@"Displaying show %@", show.description);
    self.actionButton.title = NSLocalizedString(@"Seasons", nil);
    [[FATrakt sharedInstance] detailsForShow:show callback:^(FATraktShow *show) {
        [self displayShow:show];
    } onError:nil];
    [[FATrakt sharedInstance] progressForShow:show callback:^(FATraktShowProgress *progress) {
        [self displayShow:show];
    } onError:nil];
    
    [self displayShow:show];
}

- (void)displayEpisode:(FATraktEpisode *)episode
{
    [self displayGenericContentData:episode];
    
    if (!_loadingEpisodeCounts && episode.show && !episode.show.hasEpisodeCounts) {
        _loadingEpisodeCounts = YES;
        
        [[FATrakt sharedInstance] seasonInfoForShow:episode.show callback:^(FATraktShow *show) {
            episode.show = show;
            [episode commitToCache];
            [self displayEpisode:episode];
        } onError:nil];
    }
    
    if (episode.show || (episode.episodeNumber && episode.seasonNumber)) {
        __block BOOL animated;
        
        [UIView performWithoutAnimation:^{
            NSString *displayString;
            displayString = [NSString stringWithFormat:NSLocalizedString(@"%@ - S%02iE%02i", nil), episode.show.title, episode.seasonNumber.unsignedIntegerValue, episode.episodeNumber.unsignedIntegerValue];
            
            if (episode.first_aired_utc) {
                NSString *dateString = [FAInterfaceStringProvider relativeTimeAndDateFromNowWithDate:episode.first_aired_utc];
                NSString *airString;
                
                if ([episode.first_aired_utc isLaterThanDate:[NSDate date]]) {
                    airString = [NSString stringWithFormat:@"\nAirs: %@", dateString];
                } else {
                    airString = [NSString stringWithFormat:@"\nAired: %@", dateString];
                }
                
                displayString = [displayString stringByAppendingString:airString];
            }
            
            animated = NO;
            
            if (![self.detailLabel.text isEqual:displayString]) {
                self.detailLabel.text = displayString;
                animated = YES;
            }
        }];
        
        [UIView animateSynchronizedIf:animated duration:0.3 setUp:^{
            if (self.detailViewHeightConstraint) {
                [self.detailLabel.superview removeConstraint:self.detailViewHeightConstraint];
                self.detailViewHeightConstraint = nil;
            }
            
            [self.detailLabel.superview invalidateIntrinsicContentSize];
        } animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL completed) {
            if (completed) {
                if (!_detailLabelTapGestureRecognizer) {
                    _detailLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDetailLabel:)];
                    [self.detailLabel.superview addGestureRecognizer:_detailLabelTapGestureRecognizer];
                }
            }
        }];
    }
    
    [self.view layoutIfNeeded];
}

- (void)loadEpisodeData:(FATraktEpisode *)episode
{
    self.actionButton.title = NSLocalizedString(@"Check In", nil);
    [[FATrakt sharedInstance] detailsForEpisode:episode callback:^(FATraktEpisode *episode) {
        [self displayEpisode:episode];
    } onError:nil];
    [self displayEpisode:episode];
}

- (void)displayContent:(FATraktContent *)content
{
    if (content.contentType == FATraktContentTypeMovies) {
        [self displayMovie:[((FATraktMovie *)content) cachedVersion]];
    } else if (content.contentType == FATraktContentTypeShows) {
        [self displayShow:[((FATraktShow *)content) cachedVersion]];
    } else if (content.contentType == FATraktContentTypeEpisodes) {
        [self displayEpisode:[((FATraktEpisode *)content) cachedVersion]];
    }
}

- (void)loadContent:(FATraktContent *)content
{
    _currentContent = content;
    [self loadContentData:content];
    
    if (_didLoad) {
        if (content.contentType == FATraktContentTypeMovies) {
            [self loadMovieData:[((FATraktMovie *)content) cachedVersion]];
        } else if (content.contentType == FATraktContentTypeShows) {
            [self loadShowData:[((FATraktShow *)content) cachedVersion]];
        } else if (content.contentType == FATraktContentTypeEpisodes) {
            [self loadEpisodeData:[((FATraktEpisode *)content) cachedVersion]];
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
    UIStoryboard *storyboard = self.storyboard;
    
    if (_currentContent.contentType == FATraktContentTypeMovies || _currentContent.contentType == FATraktContentTypeEpisodes) {
        if (![[FATraktConnection sharedInstance] usernameAndPasswordValid]) {
            [[FAGlobalEventHandler handler] showNeedsLoginAlertWithActionName:NSLocalizedString(@"check in", nil)];
        } else {
            FACheckinViewController *checkinViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkin"];
            [checkinViewController performCheckinForContent:_currentContent];
            [self presentViewControllerInsideNavigationController:checkinViewController animated:YES completion:nil];
        }
    } else {
        // show list of seasons
        FASeasonListViewController *seasonListViewController = [storyboard instantiateViewControllerWithIdentifier:@"seasonList"];
        [seasonListViewController loadShow:(FATraktShow *)_currentContent];
        [self.navigationController pushViewController:seasonListViewController animated:YES];
    }
}

- (void)actionDetailLabel:(UIGestureRecognizer *)recognizer
{
    if (_currentContent.contentType == FATraktContentTypeEpisodes) {
        // Bring the user to the show
        FADetailViewController *showViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [showViewController loadContent:[(FATraktEpisode *)_currentContent show]];
        [self.navigationController pushViewController:showViewController animated:YES];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self actionItem:self];
    }
}

#pragma mark Toolbar
- (IBAction)pushedBookmarkButton:(id)sender
{
    UIStoryboard *storyboard = self.storyboard;
    FAContentBookmarkViewController *bookmarkViewController = [storyboard instantiateViewControllerWithIdentifier:@"contentBookmark"];
    bookmarkViewController.delegate = self;
    [bookmarkViewController displayContent:_currentContent];
    [self presentSemiModalViewController:bookmarkViewController animated:YES completion:nil];
}

- (IBAction)pushedShareButton:(id)sender
{
    [self presentViewController:_activityViewController animated:YES completion:nil];
}

- (IBAction)actionRatingsButton:(id)sender
{
    FARatingsViewController *ratingsViewController = [[FARatingsViewController alloc] initWithContent:[_currentContent cachedVersion]];
    [self presentViewController:ratingsViewController animated:YES completion:nil];
}

#pragma Bookmark Delegate
- (void)changedPropertiesOfContent:(FATraktContent *)content
{
    [self displayGenericContentData:_currentContent];
}

#pragma mark State Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:_currentContent forKey:@"_currentContent"];
    [coder encodeFloat:self.nextUpHeightConstraint.constant forKey:@"nextUpHeightConstraint.constant"];
    [coder encodeObject:_coverImage forKey:@"_coverImage"];
    [coder encodeObject:self.navigationItem.title forKey:@"title"];
    
    [coder encodeObject:self.nextUpViewController forKey:@"nextUpViewController"];
    
    [coder encodeFloat:self.scrollView.contentOffset.y + self.scrollView.contentInset.top forKey:@"scrollOffset"];
    [coder encodeObject:self.navigationItem.title forKey:@"navigationItem.title"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.navigationItem.title = [coder decodeObjectForKey:@"navigationItem.title"];
    
    self.nextUpHeightConstraint.constant = [coder decodeFloatForKey:@"nextUpHeightConstraint.constant"];
    self.nextUpViewController = [coder decodeObjectForKey:@"nextUpViewController"];
    
    _coverImage = [coder decodeObjectForKey:@"_coverImage"];
    [self doDisplayImageAnimated:NO];
    
    _currentContent = [coder decodeObjectForKey:@"_currentContent"];
    _willRestoreState = YES;
    
    [self.view recursiveSetNeedsUpdateConstraints];
    
    _contentOffsetAfterLayout = [coder decodeFloatForKey:@"scrollOffset"];
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

#pragma mark FAPullScrollViewAccessoryViewDelegate
- (void)pullScrollViewAccessoryView:(FAPullScrollViewAccessoryView *)accessoryView endedPullingSuccessfully:(BOOL)success
{
    if (success && _currentContent.contentType == FATraktContentTypeEpisodes) {
        // Instantiate a new detail view controller with the new episode
        
        FATraktEpisode *newEpisode = nil;
        FATraktEpisode *episode = (FATraktEpisode *)_currentContent;
        FASlideAnimatedTransitionDirection direction;
        
        if (accessoryView == _previousEpisodeAccessory) {
            newEpisode = [episode previousEpisode];
            direction = FASlideAnimatedTransitionDirectionDown;
        } else if (accessoryView == _nextEpisodeAccessory) {
            newEpisode = [episode nextEpisode];
            direction = FASlideAnimatedTransitionDirectionUp;
        }
        
        if (newEpisode) {
            FADetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
            [detailVC loadContent:newEpisode];
            
            FANavigationController *navigationController = (FANavigationController *)self.navigationController;
            [navigationController replaceTopViewControllerWithViewController:detailVC usingSlideAnimation:YES direction:direction completion:nil];
        }
    }
}


@end
