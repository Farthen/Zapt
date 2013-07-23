//
//  FATraktEpisode.h
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FACacheableItem.h"

@class FATraktShow;

@interface FATraktEpisode : FATraktContent

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;
- (id)initWithSummaryDict:(NSDictionary *)dict;
- (void)mapObjectsInSummaryDict:(NSDictionary *)dict;
- (FATraktEpisode *)cachedVersion;

@property (retain) FATraktShow *show;

@property (retain) NSNumber *season;
@property (retain) NSNumber *episode;
@property (retain) NSString *title;
@property (retain) NSString *overview;
@property (retain) NSDate *first_aired;
@property (retain) NSString *url;
@property (assign) BOOL watched;



@end
