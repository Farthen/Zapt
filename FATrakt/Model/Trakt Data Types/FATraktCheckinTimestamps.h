//
//  FATraktCheckinTimestamps.h
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@interface FATraktCheckinTimestamps : FATraktDatatype

@property NSDate *start;
@property NSDate *end;
@property NSTimeInterval active_for;

@property (readonly) CGFloat progress;
@property (readonly) NSTimeInterval remaining;
@property (readonly) BOOL isOver;

@end
