//
//  FATraktCheckinResponse.h
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@class FATraktContent;
@class FATraktCheckinTimestamps;
@class FATraktMovie;
@class FATraktShow;

@interface FATraktCheckin : FATraktDatatype

@property FATraktStatus status;
@property NSString *error;
@property NSNumber *wait;

@property NSString *message;
@property FATraktContent *content;

@property BOOL facebook;
@property BOOL twitter;
@property BOOL tumblr;
@property BOOL path;

@property FATraktCheckinTimestamps *timestamps;
//@property FATraktMovie *movie;
//@property FATraktShow *show;

@end
