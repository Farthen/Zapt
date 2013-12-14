//
//  FATraktViewingSettings.m
//  Zapr
//
//  Created by Finn Wilke on 06.08.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktViewingSettings.h"

@implementation FATraktViewingSettings

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.ratings_mode = FATraktRatingsModeSimple;
    }
    
    return self;
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"ratings"]) {
        NSString *ratingsModeString = [object objectForKey:@"mode"];
        
        if ([ratingsModeString isEqualToString:@"advanced"]) {
            self.ratings_mode = FATraktRatingsModeAdvanced;
        } else {
            self.ratings_mode = FATraktRatingsModeSimple;
        }
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

@end
