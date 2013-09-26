//
//  FAInterfaceStringProvider.m
//  Zapr
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAInterfaceStringProvider.h"

@implementation FAInterfaceStringProvider

+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized
{
    return [self nameForContentType:type withPlural:plural capitalized:capitalized longVersion:NO];
}

+ (NSString *)nameForContentType:(FATraktContentType)type withPlural:(BOOL)plural capitalized:(BOOL)capitalized longVersion:(BOOL)longVersion
{
    NSString *name;
    if (!plural) {
        if (type == FATraktContentTypeMovies) {
            if (capitalized) {
                name = NSLocalizedString(@"Movie", nil);
            } else {
                name = NSLocalizedString(@"movie", nil);
            }
        } else if (type == FATraktContentTypeShows) {
            if (longVersion) {
                name = NSLocalizedString(@"TV Show", nil);
            } else if (capitalized) {
                name = NSLocalizedString(@"Show", nil);
            } else {
                name = NSLocalizedString(@"show", nil);
            }
        } else if (type == FATraktContentTypeEpisodes) {
            if (longVersion) {
                name = @"TV Episode";
            } else if (capitalized) {
                name = NSLocalizedString(@"Episode", nil);
            } else {
                name = NSLocalizedString(@"episode", nil);
            }
        }
    } else {
        if (type == FATraktContentTypeMovies) {
            if (capitalized) {
                name = NSLocalizedString(@"Movies", nil);
            } else {
                name = NSLocalizedString(@"movies", nil);
            }
        } else if (type == FATraktContentTypeShows) {
            if (longVersion) {
                name = NSLocalizedString(@"TV Shows", nil);
            } else if (capitalized) {
                name = NSLocalizedString(@"Shows", nil);
            } else {
                name = NSLocalizedString(@"shows", nil);
            }
        } else if (type == FATraktContentTypeEpisodes) {
            if (longVersion) {
                name = NSLocalizedString(@"TV Episodes", nil);
            } else if (capitalized) {
                name = NSLocalizedString(@"Episodes", nil);
            } else {
                name = NSLocalizedString(@"episodes", nil);
            }
        }
    }
    return name;
}

+ (NSString *)nameForRating:(FATraktRating)rating capitalized:(BOOL)capitalized
{
    NSString *name;
    if (rating == FATraktRatingUndefined) {
        name = NSLocalizedString(@"not rated", nil);
    } else if (rating == FATraktRatingHate) {
        name = NSLocalizedString(@"hate", nil);
    } else if (rating == FATraktRatingLove) {
        name = NSLocalizedString(@"love", nil);
    } else {
        name = [NSString stringWithFormat:@"%i", rating];
    }
    if (capitalized) {
        name = [name capitalizedString];
    }
    return name;
}

@end
