//
//  FATraktShow.h
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktWatchableBaseItem.h"

@interface FATraktShow : FATraktWatchableBaseItem

@property (retain) NSString *title;
@property (retain) NSNumber *year;
@property (retain) NSString *url;
@property (retain) NSDate *first_aired;
@property (retain) NSString *country;
@property (retain) NSNumber *runtime;
@property (retain) NSString *network;
@property (retain) NSString *air_day;
@property (retain) NSString *air_time;
@property (retain) NSString *certification;
@property (retain) NSString *imdb_id;
@property (retain) NSString *tvdb_id;
@property (retain) NSString *tvrage_id;
@property (retain) FATraktImageList *images;
@property (retain) NSArray *genres;

@property (assign) BOOL requestedDetailedInformation;

@end
