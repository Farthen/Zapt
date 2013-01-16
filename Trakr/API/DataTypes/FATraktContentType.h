//
//  FATraktContentType.h
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktImageList;

// This is the superclass of movies, shows and episodes.
@interface FATraktContentType : FATraktDatatype

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (retain) NSDictionary *ratings;

@property (retain) NSNumber *in_watchlist;
@property (retain) NSNumber *in_collection;
@property (retain) NSString *rating;
@property (retain) NSNumber *rating_advanced;

@end
