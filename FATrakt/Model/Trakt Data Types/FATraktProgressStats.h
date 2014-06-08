//
//  FATraktProgressStats.h
//  Zapt
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@interface FATraktProgressStats : FATraktDatatype

@property NSNumber *plays;
@property NSNumber *scrobbles;
@property NSNumber *checkins;
@property NSNumber *seen;

@end
