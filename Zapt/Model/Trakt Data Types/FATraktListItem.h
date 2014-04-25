//
//  FATraktListItem.h
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FACacheableItem.h"

@class FATraktMovie;
@class FATraktSeason;
@class FATraktEpisode;
@class FATraktShow;
@class FATraktContent;

@interface FATraktListItem : FATraktDatatype

@property FATraktContent *content;
@property NSString *contentCacheKey;

@property (readonly) FATraktMovie *movie;
@property (readonly) FATraktShow *show;
@property (readonly) FATraktEpisode *episode;
@property (readonly) FATraktSeason *season;

@end
