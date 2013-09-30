//
//  FATraktCheckinResponse.h
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktContent.h"

@interface FATraktCheckinResponse : FATraktDatatype

@property NSString *status;
@property NSString *error;
@property NSNumber *wait;

@property NSString *message;
@property FATraktContent *content;

@property BOOL facebook;
@property BOOL twitter;
@property BOOL tumblr;
@property BOOL path;

@end
