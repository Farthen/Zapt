//
//  FATraktShowProgress.h
//  Trakr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
@class FATraktShow;

@interface FATraktShowProgress : FATraktDatatype

@property (retain) FATraktShow *show;
@property (assign) NSNumber *percentage;
@property (assign) NSNumber *aired;
@property (assign) NSNumber *completed;
@property (assign) NSNumber *left;

@end
