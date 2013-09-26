//
//  FARatingsView.h
//  Zapr
//
//  Created by Finn Wilke on 23.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATraktContent.h"

@protocol FARatingsViewDelegate <NSObject>

- (void)ratingsViewDoneButtonPressed:(id)sender;

@end

@interface FARatingsView : UIView

@property id<FARatingsViewDelegate> delegate;
@property BOOL simpleRating;
@property FATraktRating rating;

- (void)setColorsWithImage:(UIImage *)sourceImage;

@end
