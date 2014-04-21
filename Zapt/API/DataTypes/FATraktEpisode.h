//
//  FATraktEpisode.h
//  Zapt
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FACacheableItem.h"

@class FATraktShow;
@class FATraktSeason;

@interface FATraktEpisode : FATraktContent

- (instancetype)initWithShow:(FATraktShow *)show seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber;
- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;
- (id)initWithSummaryDict:(NSDictionary *)dict;

- (void)mapObjectsInSummaryDict:(NSDictionary *)dict;

@property (readonly) NSIndexPath *previousEpisodeIndexPath;
@property (readonly) NSIndexPath *nextEpisodeIndexPath;

@property (readonly) FATraktEpisode *previousEpisode;
@property (readonly) FATraktEpisode *nextEpisode;

// These are technically weak but not declared as such
// This prevents a compiler warning
@property FATraktShow *show;
@property NSString *showCacheKey;

@property FATraktSeason *season;
@property NSString *seasonCacheKey;

@property (retain) NSNumber *seasonNumber;
@property (retain) NSNumber *episodeNumber;
@property (retain) NSString *title;
@property (retain) NSString *overview;
@property (retain) NSDate *first_aired;
@property (retain) NSString *url;
@property (assign) BOOL watched;

@property (nonatomic, retain) NSDate *first_aired_utc;

@end
