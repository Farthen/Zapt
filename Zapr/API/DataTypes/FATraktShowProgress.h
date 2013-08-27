//
//  FATraktShowProgress.h
//  Trakr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktShow;
@class FATraktEpisode;

@interface FATraktShowProgress : FATraktDatatype

@property (retain) FATraktShow *show;
@property (retain) NSNumber *percentage;
@property (retain) NSNumber *aired;
@property (retain) NSNumber *completed;
@property (retain) NSNumber *left;
@property (retain) FATraktEpisode *next_episode;

@end
