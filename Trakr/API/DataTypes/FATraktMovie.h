//
//  FATraktMovie.h
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktDatatype.h"

@class FATraktPeopleList;
@class FATraktImageList;

@interface FATraktMovie : FATraktDatatype

@property (retain) NSString *title;
@property (retain) NSNumber *year;
@property (retain) NSDate *released;
@property (retain) NSString *url;
@property (retain) NSString *trailer;
@property (retain) NSNumber *runtime;
@property (retain) NSString *tagline;
@property (retain) NSString *overview;
@property (retain) NSString *certification;
@property (retain) NSString *imdb_id;
@property (retain) NSString *tmdb_id;
@property (retain) NSString *rt_id;
@property (retain) NSDate *last_updated;
@property (retain) FATraktImageList *images;
@property (retain) NSArray *genres;
@property (retain) NSArray *top_watchers;
@property (retain) NSDictionary *ratings;
@property (retain) NSDictionary *stats;
@property (retain) FATraktPeopleList *people;
@property (retain) NSNumber *watched;
@property (retain) NSNumber *plays;
@property (retain) NSString *rating;
@property (retain) NSNumber *rating_advanced;
@property (retain) NSNumber *in_watchlist;
@property (retain) NSNumber *in_collection;

@property (assign) BOOL requestedDetailedInformation;

@end
