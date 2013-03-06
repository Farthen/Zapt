//
//  FATraktEpisode.h
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FATraktCacheable.h"

@class FATraktShow;

@interface FATraktEpisode : FATraktContent <FATraktCacheable>

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;

@property (retain) FATraktShow *show;

@property (retain) NSNumber *season;
@property (retain) NSNumber *episode;
@property (retain) NSString *title;
@property (retain) NSString *overview;
@property (retain) NSDate *first_aired;
@property (retain) NSString *url;

// watchlist API calls "episode" "number"
@property (retain) NSNumber *number;

@end
