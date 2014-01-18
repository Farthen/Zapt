//
//  FATraktContentType.h
//  Zapt
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
    FATraktContentTypeSeasons = 3,
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

typedef enum {
    FATraktWatchingTypeNotWatching = 0,
    FATraktWatchingTypeWatching = 1,
    FATraktWatchingTypeCheckin = 2
} FATraktWatchingType;

typedef enum {
    FATraktSortingOptionTitle = 0,
    FATraktSortingOptionRecentActivity = 1,
    FATraktSortingOptionMostCompleted = 2,
    FATraktSortingOptionLeastCompleted = 3,
    FATraktSortingOptionRecentlyAired = 4,
    FATraktSortingOptionPreviouslyAired = 5
} FATraktSortingOption;

// This is the superclass of movies, shows and episodes.
@interface FATraktContent : FATraktCachedDatatype

@property (readonly) FATraktContentType contentType;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (readonly) NSString *widescreenImageURL;

@property (readonly) NSString *slug;
@property (readonly) NSString *urlIdentifier;
@property (readonly) NSDictionary *postDictInfo;
@property (readonly) BOOL isWatched;
@property (assign) BOOL in_watchlist;
@property (assign) BOOL in_collection;

@property (assign) FATraktWatchingType watchingType;

@property NSDictionary *ratings;
@property FATraktRating rating;
@property FATraktRating rating_advanced;

@property (assign) FATraktDetailLevel detailLevel;

- (instancetype)cachedVersion;

@end
