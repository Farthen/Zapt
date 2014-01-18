//
//  FARatingsView.m
//  Zapr
//
//  Created by Finn Wilke on 23.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FARatingsView.h"
#import "FADominantColorsAnalyzer.h"
#import "FAColorCompositing.h"
#import "FAColorSorting.h"
#import "FAInterfaceStringProvider.h"

#import "FATraktContent.h"

@interface FARatingsView ()
@property UINavigationBar *navigationBar;

@property UIButton *likeButton;
@property UIButton *hateButton;

@property UIControl *ratingControl;
@property UILabel *ratingLabel;
@property UILabel *ratingDescriptionLabel;

@property NSArray *dominantColors;
@property NSArray *ratingNames;

@property CGPoint initialTouchLocation;
@property FATraktRating initialSegment;
@end

@implementation FARatingsView
@synthesize simpleRating = _simpleRating;
@synthesize rating = _rating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.simpleRating = YES;
        self.dominantColors = @[[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.9 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.4 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.3 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.2 green:0 blue:0 alpha:1],
                                [UIColor colorWithRed:0.1 green:0 blue:0 alpha:1]];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.navigationBar) {
        CGRect frame = self.bounds;
        frame.size.height = [self navigationBarHeight];
        self.navigationBar = [[UINavigationBar alloc] initWithFrame:frame];
        
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Rating", nil)];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(ratingsViewDoneButtonPressed:)];
        navigationItem.rightBarButtonItem = rightButton;
        [self.navigationBar setItems:@[navigationItem]];
        
        self.navigationBar.barStyle = UIBarStyleBlack;
        
        [self addSubview:self.navigationBar];
    }
    
    if (self.simpleRating) {
        [self.ratingControl removeFromSuperview];
        
        CGSize buttonSize;
        buttonSize.width = self.bounds.size.width;
        buttonSize.height = (self.bounds.size.height - self.navigationBarHeight) / 2;
        UIColor *buttonColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        
        if (!self.likeButton) {
            CGRect likeButtonFrame;
            likeButtonFrame.size = buttonSize;
            likeButtonFrame.origin.y = self.bounds.origin.y + self.navigationBarHeight;
            likeButtonFrame.origin.x = self.bounds.origin.x;
            self.likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.likeButton.frame = likeButtonFrame;
            self.likeButton.backgroundColor = buttonColor;
            self.likeButton.titleLabel.font = [UIFont systemFontOfSize:30];
            [self.likeButton setTitle:NSLocalizedString(@"Love", nil) forState:UIControlStateNormal];
            
            [self.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (!self.hateButton) {
            CGRect hateButtonFrame;
            hateButtonFrame.size = buttonSize;
            hateButtonFrame.origin.y = self.bounds.origin.y + self.navigationBarHeight + buttonSize.height;
            hateButtonFrame.origin.x = self.bounds.origin.x;
            self.hateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.hateButton.frame = hateButtonFrame;
            self.hateButton.backgroundColor = buttonColor;
            self.hateButton.titleLabel.font = [UIFont systemFontOfSize:30];
            [self.hateButton setTitle:NSLocalizedString(@"Hate", nil) forState:UIControlStateNormal];
            
            [self.hateButton addTarget:self action:@selector(hateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addSubview:self.likeButton];
        [self addSubview:self.hateButton];
        
        if (self.rating == FATraktRatingLove) {
            self.likeButton.backgroundColor = self.dominantColors[0];
            self.hateButton.backgroundColor = buttonColor;
        } else if (self.rating == FATraktRatingHate) {
            self.hateButton.backgroundColor = self.dominantColors[0];
            self.likeButton.backgroundColor = buttonColor;
        } else {
            self.likeButton.backgroundColor = buttonColor;
            self.hateButton.backgroundColor = buttonColor;
        }
        
        self.likeButton.tintColor = [self.likeButton.backgroundColor invertedColor];
        self.hateButton.tintColor = [self.hateButton.backgroundColor invertedColor];
        self.navigationBar.topItem.rightBarButtonItem.tintColor = self.tintColor;
    } else {
        [self.likeButton removeFromSuperview];
        [self.hateButton removeFromSuperview];
        
        // Complicated 10 point rating stuff
        // I mean, I know how this will look like but I don't really feel much
        // motivation on actually implementing this now.
        // But well *sigh* let's get this over with...
        
        if (self.rating <= 10 && self.rating > 0) {
            self.backgroundColor = self.dominantColors[10 - self.rating];
        } else {
            self.backgroundColor = [UIColor blackColor];
        }
        
        if (!self.ratingControl) {
            CGRect ratingFrame = self.bounds;
            ratingFrame.size.height -= self.navigationBarHeight;
            ratingFrame.origin.y += self.navigationBarHeight;
            self.ratingControl = [[UIControl alloc] initWithFrame:ratingFrame];
            [self.ratingControl addTarget:self action:@selector(didMoveFinger:withEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDown];
        }
        
        if (!self.ratingLabel) {
            self.ratingLabel = [[UILabel alloc] init];
        }
        
        self.ratingLabel.text = @"10";
        self.ratingLabel.font = [UIFont systemFontOfSize:100];
        self.ratingLabel.adjustsFontSizeToFitWidth = YES;
        
        self.ratingLabel.textAlignment = NSTextAlignmentCenter;
        
        CGRect frame = CGRectZero;
        frame.size = self.ratingLabel.intrinsicContentSize;
        frame.size.width = self.ratingControl.bounds.size.width - 20;
        self.ratingLabel.frame = frame;
        self.ratingLabel.center = [self.ratingControl convertPoint:self.center fromView:self.superview];
        
        if (!self.ratingDescriptionLabel) {
            self.ratingDescriptionLabel = [[UILabel alloc] init];
        }
        
        // Calculate the position right below the numbers
        CGFloat ratingDescriptionY = self.ratingLabel.frame.origin.y + self.ratingLabel.frame.size.height;
        
        
        if (self.rating == FATraktRatingUndefined) {
            self.ratingLabel.text = NSLocalizedString(@"Not rated", nil);
            self.ratingLabel.textColor = [UIColor whiteColor];
            self.ratingDescriptionLabel.text = NSLocalizedString(@"Slide up/down to rate", nil);
            self.ratingDescriptionLabel.textColor = [UIColor grayColor];
        } else {
            self.ratingLabel.text = [NSString stringWithFormat:@"%i", self.rating];
            
            self.ratingLabel.textColor = [UIColor whiteColor];
            
            self.ratingDescriptionLabel.hidden = NO;
            self.ratingDescriptionLabel.text = [FAInterfaceStringProvider nameForRating:self.rating ratingsMode:FATraktRatingsModeAdvanced capitalized:YES];
            self.ratingDescriptionLabel.textColor = self.ratingLabel.textColor;
        }
        
        frame = CGRectZero;
        frame.origin.y = ratingDescriptionY;
        frame.size.width = self.ratingControl.bounds.size.width;
        frame.size = self.ratingDescriptionLabel.intrinsicContentSize;
        frame.size.width = self.ratingControl.bounds.size.width - 20;
        self.ratingDescriptionLabel.frame = frame;
        self.ratingDescriptionLabel.center = CGPointMake(self.ratingLabel.center.x, self.ratingDescriptionLabel.center.y);
        self.ratingDescriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.ratingDescriptionLabel.adjustsFontSizeToFitWidth = YES;
        self.ratingDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.ratingDescriptionLabel.numberOfLines = 1;
        
        [self.ratingControl addSubview:self.ratingDescriptionLabel];
        
        /*if ([self.backgroundColor isEqual:[UIColor blackColor]]) {
         self.navigationBar.topItem.rightBarButtonItem.tintColor = self.tintColor;
         } else {
         self.navigationBar.topItem.rightBarButtonItem.tintColor = [self.backgroundColor invertedColor];
         }*/
        
        self.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        
        [self addSubview:self.ratingControl];
        [self.ratingControl addSubview:self.ratingLabel];
    }
}

- (void)didMoveFinger:(id)sender withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    // Calculate the initial position
    if (touch.phase == UITouchPhaseBegan) {
        self.initialTouchLocation = [touch locationInView:self.ratingControl];
        self.initialSegment = self.rating;
    }
    
    // Calculate the position in the view
    CGPoint touchLocation = [touch locationInView:self.ratingControl];
    
    // We use the current touch location as the starting point of the scrubbing.
    // This should make it easier to select the correct option
    
    // This height was tested on device and seems reasonable.
    CGFloat segmentHeight = 30;

    // the offset from the starting location
    CGFloat offset = self.initialTouchLocation.y - touchLocation.y;
    
    NSInteger segmentOffset = floor((offset) / segmentHeight);
    NSInteger currentSegment = self.initialSegment;
    
    NSInteger newSegment = currentSegment + segmentOffset;
    newSegment = MIN(newSegment, 10);
    newSegment = MAX(0, newSegment);
    
    self.rating = (NSUInteger)newSegment;
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self layoutIfNeeded];

}

- (void)likeButtonPressed:(id)sender
{
    self.rating = 10;
}

- (void)hateButtonPressed:(id)sender
{
    self.rating = 0;
}

- (CGFloat)navigationBarHeight
{
    return 64;
}

- (void)setSimpleRating:(BOOL)simpleRating
{
    _simpleRating = simpleRating;
    [self layoutSubviews];
}

- (BOOL)simpleRating
{
    return _simpleRating;
}

- (void)setRating:(FATraktRating)rating
{
    // just an extra sanity check, i hate when everything explodes
    if (rating > 10) {
        rating = 10;
    }
    
    _rating = rating;
    [self layoutSubviews];
}

- (FATraktRating)rating
{
    return _rating;
}

- (void)setColorsWithImage:(UIImage *)sourceImage
{
    [self layoutSubviews];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
