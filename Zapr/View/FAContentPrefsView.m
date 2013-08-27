//
//  FAContentPrefsView.m
//  Zapr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAContentPrefsView.h"
#import "FATraktContent.h"
#import "FASegmentedControl.h"
#import "FATrakt.h"

@implementation FAContentPrefsView {
    UIButton *_watchlistAddButton;
    UIImage *_watchlistAddImage;
    UIImage *_watchlistRemoveImage;
    FASegmentedControl *_loveSegmentedControl;
    UIImage *_loveImage;
    UIImage *_hateImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}

- (void)displayContent:(FATraktContent *)content
{
    if (!_watchlistAddButton) {
        _watchlistAddButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self addSubview:_watchlistAddButton];
        _watchlistAddImage = [UIImage imageNamed:@"+-mark"];
        _watchlistRemoveImage = [UIImage imageNamed:@"--mark"];
    }
    
    [_watchlistAddButton setTitle:@"  Watchlist" forState:UIControlStateNormal];
    if (content.in_watchlist) {
        [_watchlistAddButton setImage:_watchlistRemoveImage forState:UIControlStateNormal];
    } else {
        [_watchlistAddButton setImage:_watchlistAddImage forState:UIControlStateNormal];
    }
    _watchlistAddButton.frame = CGRectMake(20, 20, 120, 30);
    
    if (!_loveSegmentedControl) {
        _loveImage = [UIImage imageNamed:@"love"];
        _hateImage = [UIImage imageNamed:@"hate"];
        _loveSegmentedControl = [[FASegmentedControl alloc] initWithItems:@[_loveImage, _hateImage]];
        _loveSegmentedControl.allowDeselection = YES;
        [self addSubview:_loveSegmentedControl];
    }
    _loveSegmentedControl.frame = CGRectMake(160, 20, 100, 40);
    if (content.rating == FATraktRatingLove) {
        _loveSegmentedControl.selectedSegmentIndex = 0;
    } else if (content.rating == FATraktRatingHate) {
        _loveSegmentedControl.selectedSegmentIndex = 1;
    } else {
        _loveSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
}


@end
