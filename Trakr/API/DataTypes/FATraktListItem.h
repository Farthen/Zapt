//
//  FATraktListItem.h
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktMovie;
@class FATraktSeason;
@class FATraktEpisode;
@class FATraktShow;
@class FATraktContent;

@interface FATraktListItem : FATraktDatatype

@property (retain) NSString *type;
@property FATraktContent *content;
@property (retain) FATraktMovie *movie;
@property (retain) FATraktShow *show;
@property (retain) FATraktEpisode *episode;
@property (retain) FATraktSeason *season;

- (void)setItem:(id)object;

@end
