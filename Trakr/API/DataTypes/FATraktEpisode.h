//
//  FATraktEpisode.h
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktContentType.h"

@class FATraktShow;

@interface FATraktEpisode : FATraktContentType

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;

@property (retain) FATraktShow *show;

@property (retain) NSNumber *season;
@property (retain) NSNumber *episode;
@property (retain) NSString *title;
@property (retain) NSString *overview;
@property (retain) NSDate *first_aired;
@property (retain) NSString *url;

@property (assign) BOOL requestedDetailedInformation;

@end
