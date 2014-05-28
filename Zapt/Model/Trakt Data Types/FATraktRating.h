//
//  FATraktRating.h
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

typedef NS_ENUM(NSUInteger, FATraktRatingScore) {
    FATraktRatingUndefined = 0,
    FATraktRatingHate = 1,
    // chose 2-9 omitted
    FATraktRatingLove = 10
};

@interface FATraktRating : FATraktDatatype

@property (nonatomic) FATraktRatingScore simpleRating;
@property (nonatomic) FATraktRatingScore advancedRating;
@property (nonatomic, readonly) FATraktRatingScore mostAccurateRating;

@end
