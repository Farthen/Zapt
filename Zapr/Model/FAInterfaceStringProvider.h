//
//  FAInterfaceStringProvider.h
//  Zapr
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktContent.h"

@interface FAInterfaceStringProvider : NSObject

+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized longVersion:(BOOL)longVersion;
+ (NSString *)nameForRating:(FATraktRating)rating capitalized:(BOOL)capitalized;

@end
