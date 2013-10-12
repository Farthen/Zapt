//
//  FACheckinViewController.m
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACheckinViewController.h"
#import "FATrakt.h"
#import "RNTimer.h"

typedef enum {
    FACheckinViewStateSuccess,
    FACheckinViewStateFailed,
    FACheckinViewStateFailedCancel,
    FACheckinViewStatePerformingCheckin,
    FACheckinViewStateCancellingOldCheckin,
    FACheckinViewStateCancellingCheckin,
    FACheckinViewStateCancelled,
    FACheckinViewStateNone,
} FACheckinViewState;

@interface FACheckinViewController ()
@property CGFloat progress;

@property FATraktCheckin *checkin;
@property FATraktContent *content;

@property RNTimer *timer;

@property BOOL performingCheckin;

@property UIAlertView *checkinInProgressAlert;
@property UIActionSheet *shouldCancelActionSheet;

@property FACheckinViewState checkinViewState;
@end

@implementation FACheckinViewController {
    FACheckinViewState _checkinViewState;
}

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
    self.progressView.textLabel.text = @" ";
    
    self.nextUpViewController.nextUpText = NSLocalizedString(@"Next:", nil);
    
    self.checkinInProgressAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Checkin failed", nil)
                                         message:NSLocalizedString(@"Another checkin is already in progress. Do you want to cancel it?", nil)
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel Checkin", nil)
                               otherButtonTitles:NSLocalizedString(@"Dismiss", nil), nil];
    
    self.shouldCancelActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Cancel This Checkin?", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Don't Cancel", nil)
                                                 destructiveButtonTitle:NSLocalizedString(@"Cancel Checkin", nil)
                                                      otherButtonTitles:nil];
    
    [self reloadTimeRemaining];
    [self loadContent:self.content];
    
    if (!self.content) {
        self.checkinViewState = FACheckinViewStateNone;
        self.showNameLabel.text = @"";
    }
    
    self.reloadControl.userInteractionEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadCheckinViewState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadCheckinViewState];
}

- (void)preferredContentSizeChanged
{
    [self.nextUpViewController preferredContentSizeChanged];
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews
{
    self.progressView.fontTextStyle = UIFontTextStyleSubheadline;
    [self.progressView setNeedsLayout];
    
    self.contentNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nextUpHeightConstraint.constant = self.nextUpViewController.preferredContentSize.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkinFinished
{
    self.progressView.textLabel.text = NSLocalizedString(@"Time's up!", nil);
    [self stopUpdatingContinuously];
    
    if (self.content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)self.content;
        [[FATrakt sharedInstance] progressForShow:episode.show callback:^(FATraktShowProgress *progress) {
            [self.nextUpViewController displayProgress:progress];
        } onError:nil];
    }
}

- (void)updateContinuously
{
    if (!self.timer) {
        self.timer = [RNTimer repeatingTimerWithTimeInterval:0.1 block:^{
            [self reloadTimeRemaining];
        }];
    }
}

- (void)stopUpdatingContinuously
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)reloadTimeRemaining
{
    if (self.checkin && self.checkin.status == FATraktStatusSuccess) {
        
        self.progressView.progress = self.checkin.timestamps.progress;
        
        NSTimeInterval remaining = self.checkin.timestamps.remaining;
        
        if (!self.checkin.timestamps.isOver) {
            NSString *timeString = nil;
            NSUInteger interval = floor(remaining);
            
            NSUInteger seconds = interval % 60;
            NSUInteger minutes = (interval / 60) % 60;
            NSUInteger hours = (interval / (60 * 60));
            
            if (remaining < 60) {
                timeString = [NSString stringWithFormat:NSLocalizedString(@"%i seconds", nil), seconds];
            } else if (remaining < 60 * 60) {
                timeString = [NSString stringWithFormat:NSLocalizedString(@"%i minutes", nil), minutes];
            } else {
                timeString = [NSString stringWithFormat:NSLocalizedString(@"%ih %imin", nil), hours, minutes];
            }
            
            self.progressView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Time remaining: %@", nil), timeString];
        } else {
            [self checkinFinished];
        }
    } else {
        self.progressView.progress = 0;
        self.progressView.textLabel.text = @" ";
    }
}

- (void)loadContent:(FATraktContent *)content
{
    self.content = content;
    if (content.contentType == FATraktContentTypeEpisodes) {
        FATraktEpisode *episode = (FATraktEpisode *)content;
        self.nextUpViewController.dismissesModalToDisplay = YES;
        [self.nextUpViewController displayProgress:episode.show.progress];
        
        NSString *showNameString = [NSString stringWithFormat:@"%@ S%iE%i", episode.show.title, episode.season.unsignedIntegerValue, episode.episode.unsignedIntegerValue];
        self.showNameLabel.text = showNameString;
        
        FATraktEpisode *nextEpisode = [episode nextEpisode];
        if (!nextEpisode) {
            [[FATrakt sharedInstance] seasonInfoForShow:episode.show callback:^(FATraktShow *show) {
                [self.nextUpViewController displayNextUp:[episode nextEpisode]];
            } onError:nil];
        } else {
            [self.nextUpViewController displayNextUp:nextEpisode];
        }
    } else {
        self.showNameLabel.text = nil;
    }
    
    self.contentNameLabel.text = content.title;
    
    [self.view setNeedsLayout];
}

- (void)reloadCheckinViewState
{
    self.statusControl.userInteractionEnabled = NO;
    FACheckinViewState state = self.checkinViewState;
    
    if (state == FACheckinViewStatePerformingCheckin) {
        self.messageLabel.text = NSLocalizedString(@"Performing Checkin.\nPlease wait…", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateReloading;
        
    } else if (state == FACheckinViewStateCancellingCheckin) {
        self.messageLabel.text = NSLocalizedString(@"Cancelling checkin.\nPlease wait…", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateReloading;
        
    } else if (state == FACheckinViewStateCancellingOldCheckin) {
        self.messageLabel.text = NSLocalizedString(@"Cancelling old checkin.\nPlease wait…", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateReloading;
        
    } else if (state == FACheckinViewStateSuccess) {
        self.statusControl.userInteractionEnabled = YES;
        self.messageLabel.text = NSLocalizedString(@"Checkin successful!", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateFinished;
        
    } else if (state == FACheckinViewStateFailed) {
        self.statusControl.userInteractionEnabled = YES;
        self.messageLabel.text = NSLocalizedString(@"An error occured checking in.\nYou can try again.", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateError;
        
    } else if (state == FACheckinViewStateCancelled) {
        [self stopUpdatingContinuously];
        self.progressView.textLabel.text = @" ";
        self.progressView.progress = 0;
        
        self.messageLabel.text = NSLocalizedString(@"Cancelled checkin.", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateFinished;
        
    } else if (state == FACheckinViewStateFailedCancel) {
        self.statusControl.userInteractionEnabled = YES;
        self.messageLabel.text = NSLocalizedString(@"Failed to cancel checkin.", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateError;
        
    } else {
        self.messageLabel.text = NSLocalizedString(@" ", nil);
        self.reloadControl.reloadControlState = FAReloadControlStateReloading;
    }
}

- (void)setCheckinViewState:(FACheckinViewState)state
{
    _checkinViewState = state;
    [self reloadCheckinViewState];
}

- (FACheckinViewState)checkinViewState
{
    return _checkinViewState;
}

- (void)loadCheckin:(FATraktCheckin *)checkin
{
    self.checkin = checkin;
    
    if (checkin) {
        [self loadContent:checkin.content];
        [self updateContinuously];
    } else {
        [self stopUpdatingContinuously];
        self.progressView.textLabel.text = @" ";
        self.progressView.progress = 0;
    }
    
    if (checkin && checkin.status == FATraktStatusFailed) {
        [self.checkinInProgressAlert show];
    }
    
    if (self.performingCheckin) {
        self.checkinViewState = FACheckinViewStatePerformingCheckin;
    } else if (checkin && checkin.status == FATraktStatusSuccess) {
        self.checkinViewState = FACheckinViewStateSuccess;
    } else {
        self.checkinViewState = FACheckinViewStateFailed;
    }
}

- (void)performCheckinForContent:(FATraktContent *)content
{
    if (!self.performingCheckin) {
        self.performingCheckin = YES;
        self.checkinViewState = FACheckinViewStatePerformingCheckin;
        
        [self loadContent:content];
        [[FATrakt sharedInstance] checkIn:content callback:^(FATraktCheckin *response) {
            self.performingCheckin = NO;
            [self loadCheckin:response];
        } onError:^(FATraktConnectionResponse *connectionError) {
            self.performingCheckin = NO;
            [self loadCheckin:nil];
        }];
    }
}

- (IBAction)actionStatusControl:(id)sender
{
    if (self.checkinViewState == FACheckinViewStateFailed) {
        [self performCheckinForContent:self.content];
    } else if (self.checkinViewState == FACheckinViewStateSuccess) {
        [self.shouldCancelActionSheet showInView:self.view];
    } else if (self.checkinViewState == FACheckinViewStateFailedCancel) {
        [[FATrakt sharedInstance] cancelCheckInForContentType:self.content.contentType callback:^(FATraktStatus status) {
            if (status == FATraktStatusSuccess) {
                [self performCheckinForContent:self.content];
            } else {
                self.checkinViewState = FACheckinViewStateFailed;
            }
        }];
    }
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.checkinInProgressAlert) {
        if (buttonIndex == 0) {
            // Cancel the other checkin and check into the new one
            self.checkinViewState = FACheckinViewStateCancellingOldCheckin;
            
            [[FATrakt sharedInstance] cancelCheckInForContentType:self.content.contentType callback:^(FATraktStatus status) {
                if (status == FATraktStatusSuccess) {
                    [self performCheckinForContent:self.content];
                } else {
                    self.checkinViewState = FACheckinViewStateFailed;
                }
            }];
        }
    }
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.shouldCancelActionSheet) {
        if (buttonIndex == 0) {
            // Cancel this checkin
            self.checkinViewState = FACheckinViewStateCancellingCheckin;
            
            [[FATrakt sharedInstance] cancelCheckInForContentType:self.content.contentType callback:^(FATraktStatus status) {
                if (status == FATraktStatusSuccess) {
                    self.checkinViewState = FACheckinViewStateCancelled;
                } else {
                    self.checkinViewState = FACheckinViewStateFailedCancel;
                }
            }];
        }
    }
}

@end
