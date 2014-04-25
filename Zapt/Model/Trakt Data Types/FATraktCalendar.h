//
//  FATraktCalendar.h
//  Zapt
//
//  Created by Finn Wilke on 18/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"

@interface FATraktCalendar : FATraktCachedDatatype

- (instancetype)initWithJSONArray:(NSArray *)array;
+ (instancetype)cachedCalendar;

@property (nonatomic) NSArray *calendarItems;
@property (nonatomic) NSDate *fromDate;
@property (nonatomic) NSUInteger dayCount;

@end
