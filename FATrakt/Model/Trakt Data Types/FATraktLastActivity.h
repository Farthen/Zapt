//
//  FATraktLastActivity.h
//  Zapt
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"

@interface FATraktLastActivity : FATraktCachedDatatype


@property NSNumber *all;
@property NSDictionary *movie;
@property NSDictionary *show;
@property NSDictionary *episode;

@property NSDate *fetchDate;

- (NSSet *)changedPathsToActivity:(FATraktLastActivity *)otherActivity;

@end
