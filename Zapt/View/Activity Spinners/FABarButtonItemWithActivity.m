//
//  FABarButtonItemWithActivity.m
//  Zapt
//
//  Created by Finn Wilke on 09/03/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FABarButtonItemWithActivity.h"

@implementation FABarButtonItemWithActivity {
    NSInteger _startCount;
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    
    if (self) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return self;
}

- (void)startActivityWithCount:(NSInteger)count
{
    self.startCount += count;
}

- (void)startActivity
{
    self.startCount += 1;
}

- (void)finishActivity
{
    self.startCount -= 1;
}

- (void)startAnimating
{
    self.customView = self.activityIndicatorView;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.customView = nil;
}

- (NSInteger)startCount
{
    return _startCount;
}

- (void)setStartCount:(NSInteger)startCount
{
    if (startCount < 0) {
        startCount = 0;
    }
    
    _startCount = startCount;
    
    if (_startCount > 0) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

@end
