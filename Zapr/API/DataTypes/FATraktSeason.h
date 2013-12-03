//
//  FATraktSeason.h
//  Zapr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@class FATraktImageList;
@class FATraktShow;
@class FATraktEpisode;

@interface FATraktSeason : FATraktDatatype

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;
- (FATraktEpisode *)episodeWithID:(NSUInteger)episodeID;

// This is technically weak but not declared as such
// This prevents a compiler warning
@property FATraktShow *show;

@property (retain) NSMutableArray *episodes;
@property (retain) NSNumber *episodeCount;
@property (retain) FATraktImageList *images;
@property (retain) NSString *poster;
@property (retain) NSNumber *seasonNumber;
@property (retain) NSString *url;

@end
