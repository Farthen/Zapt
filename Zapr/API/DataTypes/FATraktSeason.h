//
//  FATraktSeason.h
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"
#import "FATraktContent.h"

@class FATraktImageList;
@class FATraktShow;
@class FATraktEpisode;
@class FATraktSeasonProgress;

@interface FATraktSeason : FATraktCachedDatatype

- (instancetype)initWithShow:(FATraktShow *)show seasonNumber:(NSNumber *)seasonNumber;
- (instancetype)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;
- (FATraktEpisode *)episodeWithID:(NSUInteger)episodeID;

// This is technically weak but not declared as such
// This prevents a compiler warning
@property FATraktShow *show;
@property NSString *showCacheKey;

@property (readonly) NSArray *episodes;
@property NSArray *episodeCacheKeys;

@property (retain) NSMutableDictionary *episodesDict;
- (void)addEpisode:(FATraktEpisode *)episode;
- (FATraktEpisode *)episodeForNumber:(NSNumber *)number;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (id)objectForKeyedSubscript:(id)key;

@property FATraktSeasonProgress *seasonProgress;

@property (retain) NSNumber *episodeCount;
@property (readonly) NSNumber *episodesWatched;

@property (retain) FATraktImageList *images;
@property (retain) NSString *poster;
@property (retain) NSNumber *seasonNumber;
@property (retain) NSString *url;

@property (assign) FATraktDetailLevel detailLevel;

@end
