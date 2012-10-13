//
//  FATableViewCellWithActivity.m
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATableViewCellWithActivity.h"

@implementation FATableViewCellWithActivity {
    BOOL _userInteractionsEnabledState;
}

@synthesize activityIndicatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.activityIndicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.activityIndicatorView.center = self.textLabel.center;
}

- (void)startActivity
{
    _userInteractionsEnabledState = self.userInteractionEnabled;
    self.userInteractionEnabled = NO;
    self.textLabel.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)finishActivity
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.textLabel.hidden = NO;
    self.userInteractionEnabled = _userInteractionsEnabledState;
}

@end
