//
//  FATraktContentType.h
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktImageList;

typedef enum {
    FAContentTypeMovies = 0,
    FAContentTypeShows = 1,
    FAContentTypeEpisodes = 2
} FAContentType;

// This is the superclass of movies, shows and episodes.
@interface FATraktContent : FATraktDatatype

@property (readonly) FAContentType contentType;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (retain) NSString *ratings;

@property (assign) BOOL in_watchlist;
@property (assign) BOOL in_collection;
@property (retain) NSString *rating;
@property (retain) NSNumber *rating_advanced;

@property (assign) BOOL requestedDetailedInformation;
@property (assign) BOOL loadedDetailedInformation;

@end
