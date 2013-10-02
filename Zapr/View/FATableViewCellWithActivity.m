//
//  FATableViewCellWithActivity.m
//  Zapr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATableViewCellWithActivity.h"
#import "FAStatusBarSpinnerController.h"

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
    self.userInteractionEnabled = YES;
}

- (void)shakeTextLabelCompletion:(void (^)(void))completion
{
    CGPoint centerPosition = self.textLabel.center;
    CGPoint leftPosition = CGPointMake(centerPosition.x - 10, centerPosition.y);
    CGPoint rightPosition = CGPointMake(centerPosition.x + 10, centerPosition.y);
    
    [UIView animateSynchronizedIf:YES duration:0.05 setUp:nil animations:^{
        self.textLabel.center = leftPosition;
    } completion:nil];
    [UIView animateSynchronizedIf:YES duration:0.05 setUp:nil animations:^{
        self.textLabel.center = rightPosition;
    } completion:nil];
    [UIView animateSynchronizedIf:YES duration:0.05 setUp:nil animations:^{
        self.textLabel.center = leftPosition;
    } completion:nil];
    [UIView animateSynchronizedIf:YES duration:0.05 setUp:nil animations:^{
        self.textLabel.center = centerPosition;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];

}

@end
