//
//  FATraktShowProgress.h
//  Zapt
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktShow;
@class FATraktEpisode;
@class FATraktSeasonProgress;

@interface FATraktShowProgress : FATraktDatatype

@property (weak) FATraktShow *show;
@property (retain) NSNumber *percentage;
@property (retain) NSNumber *aired;
@property (retain) NSNumber *completed;
@property (retain) NSNumber *left;
@property (weak) FATraktEpisode *next_episode;
@property (retain) FATraktSeasonProgress *seasonProgress;

@end
