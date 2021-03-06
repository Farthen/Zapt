//
//  FATraktMovie.h
//  Zapt
//
//  Created by Finn Wilke on 09.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktWatchableBaseItem.h"
#import "FACacheableItem.h"

@class FATraktPeopleList;
@class FATraktImageList;

@interface FATraktMovie : FATraktWatchableBaseItem <FACacheableItem>

@property (retain) NSDate *released;
@property (retain) NSString *rt_id;
@property (retain) NSString *trailer;
@property (retain) NSString *tagline;
@property BOOL watched;
@property (retain) NSNumber *plays;

@end
