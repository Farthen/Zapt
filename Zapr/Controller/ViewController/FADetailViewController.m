//
//  FADetailViewController.m
//  Zapr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FADetailViewController.h"

#import "FAEpisodeListViewController.h"
#import "FANextUpViewController.h"
#import "FAContentBookmarkViewController.h"
#import "FARatingsViewController.h"

#import "FATraktActivityItemSource.h"
#import <TUSafariActivity/TUSafariActivity.h>

#import "FAInterfaceStringProvider.h"

#import "UIView+FrameAdditions.h"
#import "NSObject+PerformBlock.h"
#import "UIView+Animations.h"

#import "FATitleLabel.h"
#import "FAProgressHUD.h"

#import "FATrakt.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_VIEWCONTROLLER

@interface FADetailViewController () {
    BOOL _showing;
    BOOL _willAppear;
    
    FATraktContent *_currentContent;
    FATraktAccountSettings *_accountSettings;
    
    BOOL _loadContent;
    
    BOOL _animatesLayoutChanges;
    
    UIImage *_coverImage;
    
    BOOL _imageLoaded;
    BOOL _imageDisplayed;
    BOOL _willDisplayImage;
    BOOL _displayImageWhenFinishedShowing;
    
    UITapGestureRecognizer *_detailLabelTapGestureRecognizer;
    UIActivityViewController *_activityViewController;
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
    
    self.actionButton.possibleTitles = [NSSet setWithObjects:NSLocalizedString(@"Check In", nil), NSLocalizedString(@"Episodes", nil), nil];
    self.ratingsButton.title = @"";
    
    if (_loadContent) {
        _currentContent = [_currentContent cachedVersion];
        self.navigationItem.title = [FAInterfaceStringProvider nameForContentType:_currentContent.contentType withPlural:NO capitalized:YES longVersion:YES];
        
        [self loadContentData:_currentContent];
        
        if (_currentContent.contentType == FATraktContentTypeMovies) {
            [self loadMovieData:(FATraktMovie *)_currentContent];
        } else if (_currentContent.contentType == FATraktContentTypeShows) {
            [self loadShowData:(FATraktShow *)_currentContent];
        } else if (_currentContent.contentType == FATraktContentTypeEpisodes) {
            [self loadEpisodeData:(FATraktEpisode *)_currentContent];
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
    
    if (!_detailLabelTapGestureRecognizer) {
        _detailLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDetailLabel:)];
        [self.detailLabel addGestureRecognizer:_detailLabelTapGestureRecognizer];
    }
    
    _willAppear = YES;
    _animatesLayoutChanges = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self displayRatingForContent:_currentContent ratingsMode:_accountSettings.viewing.ratings_mode];
    
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateViewConstraints];
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.coverImageView invalidateIntrinsicContentSize];
    [self.view layoutIfNeeded];
    [self viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated {
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
        [UIView animateSynchronizedIf:_animatesLayoutChanges duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut setUp:^{
            [self.nextUpViewController displayNextUp:content];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)doDisplayImageAnimated:(BOOL)animated
{
    if (!_willDisplayImage) {
        if (!_imageDisplayed) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Scale the image first to screen dimensions
                
                CGSize newSize = self.coverImageView.frame.size;
                UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
                [_coverImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (animated) {
                        _willDisplayImage = YES;
                        [UIView transitionWithView:self.coverImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            self.coverImageView.image = scaledImage;
                            _willDisplayImage = NO;
                            _imageDisplayed = YES;
                        } completion:nil];
                    } else {
                        self.coverImageView.image = scaledImage;
                        _imageDisplayed = YES;
                    }
                });
            });
        }
        
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
    self.overviewLabel.text = overview;
}

- (void)displayProgress:(FATraktShowProgress *)progress
{
    if (progress) {
        [UIView animateSynchronizedIf:_animatesLayoutChanges duration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn setUp:^{
            [self.nextUpViewController displayProgress:progress];
            self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
        } animations:^{
            [self.contentView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        } completion:^(BOOL finished){
            [self setNextUpViewWithContent:progress.next_episode];
        }];
    }
}

- (void)displayRatingForContent:(FATraktContent *)content ratingsMode:(FATraktRatingsMode)ratingMode
{
    if (content) {
        if (content.rating != FATraktRatingUndefined) {
            NSString *ratingString;
            if (ratingMode == FATraktRatingsModeAdvanced) {
                ratingString = [FAInterfaceStringProvider nameForRating:content.rating_advanced ratingsMode:ratingMode capitalized:YES];
            } else {
                ratingString = [FAInterfaceStringProvider nameForRating:content.rating ratingsMode:ratingMode capitalized:YES];
            }
            self.ratingsButton.title = [NSString stringWithFormat:@"Rating: %@", ratingString];
        } else {
            self.ratingsButton.title = [NSString stringWithFormat:NSLocalizedString(@"Rating: Not rated", nil)];
        }
    } else {
        self.ratingsButton.title = nil;
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
    self.actionButton.title = NSLocalizedString(@"Episodes", nil);
    [[FATrakt sharedInstance] detailsForShow:show callback:^(FATraktShow *show) {
        [self displayShow:show];
    } onError:nil];
    [[FATrakt sharedInstance] progressForShow:show callback:^(FATraktShowProgress *progress){
        [self displayShow:show];
    } onError:nil];
    [self displayShow:show];
}

- (void)displayEpisode:(FATraktEpisode *)episode
{
    [self displayGenericContentData:episode];
    
    if (episode.show || (episode.episode && episode.season)) {
        NSString *displayString;
        if (episode.show && episode.episode && episode.season) {
            displayString = [NSString stringWithFormat:NSLocalizedString(@"%@ - S%02iE%02i", nil) , episode.show.title, episode.episode.unsignedIntegerValue, episode.season.unsignedIntegerValue];
        }
        self.detailLabel.text = displayString;
        [UIView animateSynchronizedIf:_animatesLayoutChanges duration:0.3 setUp:^{
            if (self.detailViewHeightConstraint) {
                [self.detailLabel.superview removeConstraint:self.detailViewHeightConstraint];
                self.detailViewHeightConstraint = nil;
            }
            [self.detailLabel.superview invalidateIntrinsicContentSize];
        } animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
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

- (void)loadContent:(FATraktContent *)content
{
    _currentContent = content;
    [self loadContentData:content];
    
    if (_willAppear) {
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
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;

    if (_currentContent.contentType == FATraktContentTypeMovies || _currentContent.contentType == FATraktContentTypeEpisodes) {
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

- (IBAction)actionDetailLabel:(UITapGestureRecognizer *)recognizer
{
    if (_currentContent.contentType == FATraktContentTypeEpisodes) {
        // Bring the user to the show
        FADetailViewController *showViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        [showViewController loadShowData:(FATraktShow *)_currentContent];
        [self.navigationController presentViewController:showViewController animated:YES completion:nil];
    }
}

#pragma mark Toolbar
- (IBAction)pushedBookmarkButton:(id)sender
{
    UIStoryboard *storyboard = self.view.window.rootViewController.storyboard;
    FAContentBookmarkViewController *bookmarkViewController = [storyboard instantiateViewControllerWithIdentifier:@"contentBookmark"];
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
