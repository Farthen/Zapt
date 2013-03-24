//
//  FATraktContentType.h
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FACacheableItem.h"
@class FATraktImageList;

typedef enum {
    FATraktContentTypeMovies = 0,
    FATraktContentTypeShows = 1,
    FATraktContentTypeEpisodes = 2,
    FATraktContentTypeNone = -1,
} FATraktContentType;

typedef enum {
    FATraktLibraryTypeNone = -1,
    FATraktLibraryTypeAll = 0,
    FATraktLibraryTypeCollection = 1,
    FATraktLibraryTypeWatched = 2,
} FATraktLibraryType;

typedef enum {
    FATraktDetailLevelMinimal = -1,
    FATraktDetailLevelDefault = 0,
    FATraktDetailLevelExtended = 1,
} FATraktDetailLevel;

// This is the superclass of movies, shows and episodes.
@interface FATraktContent : FATraktDatatype

@property (readonly) FATraktContentType contentType;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (retain) NSString *ratings;

@property (assign) BOOL in_watchlist;
@property (assign) BOOL in_collection;
@property (retain) NSString *rating;
@property (retain) NSNumber *rating_advanced;

@property (assign) FATraktDetailLevel detailLevel;
@end
