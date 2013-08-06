//
//  FATraktAccountSettings.h
//  Trakr
//
//  Created by Finn Wilke on 06.08.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCachedDatatype.h"
@class FATraktViewingSettings;

@interface FATraktAccountSettings : FATraktCachedDatatype

@property BOOL success;
@property NSDictionary *profile;
@property NSDictionary *account;
@property FATraktViewingSettings *viewing;
@property NSDictionary *connections;

@end
