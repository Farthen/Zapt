//
//  FATraktRating.m
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktRating.h"

@implementation FATraktRating

- (FATraktRatingScore)mostAccurateRating
{
    if (self.advancedRating != FATraktRatingUndefined) {
        return self.advancedRating;
    }
    
    return self.simpleRating;
}

- (id)newValueForMergingKey:(NSString *)key fromOldObject:(id)oldObject propertyInfo:(FAPropertyInfo *)propertyInfo
{
    return [self valueForKey:key];
}

@end
