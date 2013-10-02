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
    self.progressView.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self reloadTimeRemaining];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.progressView.textLabel.text = NSLocalizedString(@"Time's up!", nil);
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

- (void)loadContent:(FATraktContent *)content
{
    self.content = content;
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

@end
