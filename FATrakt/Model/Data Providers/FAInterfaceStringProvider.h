//
//  FAInterfaceStringProvider.h
//  Zapt
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktAPI.h"

@interface FAInterfaceStringProvider : NSObject

+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized;
+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized longVersion:(BOOL)longVersion;
+ (NSString *)nameForRatingScore:(FATraktRatingScore)rating ratingsMode:(FATraktRatingsMode)ratingsMode capitalized:(BOOL)capitalized;

+ (NSString *)nameForSeason:(FATraktSeason *)season capitalized:(BOOL)capitalized;
+ (NSString *)nameForEpisode:(FATraktEpisode *)episode long:(BOOL)longName capitalized:(BOOL)capitalized;

+ (NSString *)progressForProgress:(FATraktShowProgress *)progress long:(BOOL)longName;
+ (NSString *)progressForShow:(FATraktShow *)show long:(BOOL)longName;
+ (NSString *)progressForSeason:(FATraktSeason *)season long:(BOOL)longName;

+ (NSString *)relativeDateFromNowWithDate:(NSDate *)date;
+ (NSString *)relativeTimeAndDateFromNowWithDate:(NSDate *)date;

@end
