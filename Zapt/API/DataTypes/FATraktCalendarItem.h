//
//  FATraktCalendarItem.h
//  Zapt
//
//  Created by Finn Wilke on 18/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"
#import "FATraktEpisode.h"

@interface FATraktCalendarItem : FATraktDatatype

@property (nonatomic) NSDate *date;
@property (nonatomic) NSArray *episodes;
@property (nonatomic, readonly) NSArray *episodeCacheKeys;

@end
