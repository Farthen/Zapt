//
//  FATraktMovie.h
//  Trakr
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktWatchableBaseItem.h"
#import "FATraktCacheable.h"

@class FATraktPeopleList;
@class FATraktImageList;

@interface FATraktMovie : FATraktWatchableBaseItem <FATraktCacheable>

@property (retain) NSDate *released;
@property (retain) NSString *rt_id;
@property (retain) NSString *trailer;
@property (retain) NSString *tagline;
@property (retain) NSNumber *watched;
@property (retain) NSNumber *plays;

@end
