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
#import "FATraktRating.h"
@class FATraktImageList;

typedef NS_ENUM(NSInteger, FATraktContentType) {
    FATraktContentTypeMovies = 0,
    FATraktContentTypeShows = 1,
    FATraktContentTypeEpisodes = 2,
    FATraktContentTypeSeasons = 3,
    FATraktContentTypeNone = -1,
};

typedef NS_ENUM(NSInteger, FATraktLibraryType) {
    FATraktLibraryTypeNone = -1,
    FATraktLibraryTypeAll = 0,
    FATraktLibraryTypeCollection = 1,
    FATraktLibraryTypeWatched = 2,
};

typedef NS_ENUM(NSInteger, FATraktDetailLevel) {
    FATraktDetailLevelMinimal = -1,
    FATraktDetailLevelDefault = 0,
    FATraktDetailLevelExtended = 1,
};

typedef NS_ENUM(NSUInteger, FATraktRatingsMode) {
    FATraktRatingsModeSimple = 0,
    FATraktRatingsModeAdvanced
};

typedef NS_ENUM(NSUInteger, FATraktWatchingType) {
    FATraktWatchingTypeNotWatching = 0,
    FATraktWatchingTypeWatching = 1,
    FATraktWatchingTypeCheckin = 2
};

typedef NS_ENUM(NSUInteger, FATraktSortingOption) {
    FATraktSortingOptionTitle = 0,
    FATraktSortingOptionRecentActivity = 1,
    FATraktSortingOptionMostCompleted = 2,
    FATraktSortingOptionLeastCompleted = 3,
    FATraktSortingOptionRecentlyAired = 4,
    FATraktSortingOptionPreviouslyAired = 5
};

// This is the superclass of movies, shows and episodes.
@interface FATraktContent : FATraktCachedDatatype

@property (readonly) FATraktContentType contentType;

@property (retain) NSString *title;
@property (retain) NSString *url;
@property (retain) NSString *overview;

@property (retain) FATraktImageList *images;
@property (readonly) NSString *widescreenImageURL;
@property (readonly) NSString *posterImageURL;

- (UIImage *)widescreenImageWithWidth:(NSInteger)width;
- (UIImage *)posterImageWithWidth:(NSInteger)width;
- (void)widescreenImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback;
- (void)posterImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback;

@property (readonly) NSString *slug;
@property (readonly) NSString *urlIdentifier;
@property (readonly) NSDictionary *postDictInfo;
@property (readonly) BOOL isWatched;
@property (assign) BOOL in_watchlist;
@property (assign) BOOL in_collection;

// Ony important for some library stuff (?)
@property (nonatomic) NSInteger plays;
@property (nonatomic) BOOL unseen;

@property (assign) FATraktWatchingType watchingType;

@property NSDictionary *ratings;
@property FATraktRating *rating;

@property (assign) FATraktDetailLevel detailLevel;

- (instancetype)cachedVersion;

@end
