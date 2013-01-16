//
//  FATraktWatchableBaseItem.h
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktContentType.h"
@class FATraktPeopleList;

// This is the superclass for movies and shows.
@interface FATraktWatchableBaseItem : FATraktContentType

@property (retain) NSNumber *year;
@property (retain) NSString *imdb_id;
@property (retain) NSString *tmdb_id;
@property (retain) NSNumber *runtime;
@property (retain) NSString *certification;

@property (retain) NSDate *last_updated;

@property (retain) FATraktPeopleList *people;
@property (retain) NSDictionary *stats;
@property (retain) NSArray *genres;
@property (retain) NSArray *top_watchers;

@end