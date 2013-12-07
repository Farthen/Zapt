//
//  FATraktSeason.h
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"

@class FATraktImageList;
@class FATraktShow;
@class FATraktEpisode;

@interface FATraktSeason : FATraktCachedDatatype

- (instancetype)initWithShow:(FATraktShow *)show seasonNumber:(NSNumber *)seasonNumber;
- (instancetype)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;
- (FATraktEpisode *)episodeWithID:(NSUInteger)episodeID;

// This is technically weak but not declared as such
// This prevents a compiler warning
@property FATraktShow *show;
@property NSString *showCacheKey;

@property (retain) NSMutableArray *episodes;
@property NSArray *episodeCacheKeys;

@property (retain) NSNumber *episodeCount;
@property (readonly) NSNumber *episodesWatched;

@property (retain) FATraktImageList *images;
@property (retain) NSString *poster;
@property (retain) NSNumber *seasonNumber;
@property (retain) NSString *url;

@end
