//
//  FATraktContentType.h
//  Zapr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktCachedDatatype.h"
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

typedef enum {
    FATraktRatingUndefined = 0,
    FATraktRatingHate = 1,
    // chose 2-9 omitted
    FATraktRatingLove = 10
} FATraktRating;

typedef enum {
    FATraktRatingsModeSimple = 0,
    FATraktRatingsModeAdvanced
} FATraktRatingsMode;

// This is the superclass of movies, shows and episodes.
@interface FATraktContent : FATraktCachedDatatype

@property (readonly) FATraktContentType contentType;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (readonly) NSString *widescreenImageURL;
@property (retain) NSString *ratings;

@property (assign) BOOL in_watchlist;
@property (assign) BOOL in_collection;
@property FATraktRating rating;
@property FATraktRating rating_advanced;

@property (assign) FATraktDetailLevel detailLevel;

- (instancetype)cachedVersion;

@end
