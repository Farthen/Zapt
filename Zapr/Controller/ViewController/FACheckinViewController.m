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

@interface FACheckinViewController ()
@property CGFloat progress;

@property FATraktCheckin *checkin;
@property FATraktContent *content;

@property RNTimer *timer;
@end

@implementation FACheckinViewController

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
    
    [self reloadTimeRemaining];
    [self loadContent:self.content];
}

- (void)preferredContentSizeChanged
{
    [self.nextUpViewController preferredContentSizeChanged];
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews
{
    self.progressView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
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
    if (self.checkin) {
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
        
        FATraktEpisode *nextEpisode = [episode nextEpisode];
        if (!nextEpisode) {
            [[FATrakt sharedInstance] seasonInfoForShow:episode.show callback:^(FATraktShow *show) {
                [self.nextUpViewController displayNextUp:[episode nextEpisode]];
            } onError:nil];
        } else {
            [self.nextUpViewController displayNextUp:nextEpisode];
        }
    }
    
    self.contentNameLabel.text = content.title;
    
    [self.view setNeedsLayout];
}

- (void)loadCheckin:(FATraktCheckin *)checkin
{
    self.checkin = checkin;
    
    if (checkin.movie) {
        [self loadContent:checkin.movie];
    } else if (checkin.show) {
        [self loadContent:checkin.show];
    }
    
    if (checkin.status == FATraktStatusSuccess) {
        [self reloadTimeRemaining];
    }
}

- (IBAction)actionDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
