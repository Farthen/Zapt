//
//  FATraktSeasonProgress.h
//  Zapt
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktSeason;

@interface FATraktSeasonProgress : FATraktDatatype

- (instancetype)initWithJSONDict:(NSDictionary *)dict andSeason:(FATraktSeason *)season;

@property __weak FATraktSeason *season;

@property NSNumber *percentage;
@property NSNumber *aired;
@property NSNumber *completed;
@property NSNumber *left;
@property NSDictionary *episodes;

@end
