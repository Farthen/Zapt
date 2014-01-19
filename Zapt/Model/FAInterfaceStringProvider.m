//
//  FAInterfaceStringProvider.m
//  Zapt
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAInterfaceStringProvider.h"

@implementation FAInterfaceStringProvider

static NSArray *_ratingNames;
+ (void)initialize
{
    _ratingNames = @[NSLocalizedString(@"Not rated", nil),
                     NSLocalizedString(@"Weak sauce :(", nil),
                     NSLocalizedString(@"Terrible", nil),
                     NSLocalizedString(@"Bad", nil),
                     NSLocalizedString(@"Poor", nil),
                     NSLocalizedString(@"Meh", nil),
                     NSLocalizedString(@"Fair", nil),
                     NSLocalizedString(@"Good", nil),
                     NSLocalizedString(@"Great", nil),
                     NSLocalizedString(@"Superb", nil),
                     NSLocalizedString(@"Totally ninja!", nil)];
}

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
                name = NSLocalizedString(@"TV Episode", nil);
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

+ (NSString *)nameForRating:(FATraktRating)rating ratingsMode:(FATraktRatingsMode)ratingsMode capitalized:(BOOL)capitalized
{
    NSString *name;
    
    if (ratingsMode == FATraktRatingsModeSimple) {
        if (rating == FATraktRatingUndefined) {
            name = NSLocalizedString(@"not rated", nil);
        } else if (rating == FATraktRatingHate) {
            name = NSLocalizedString(@"hate", nil);
        } else if (rating == FATraktRatingLove) {
            name = NSLocalizedString(@"love", nil);
        } else {
            name = [NSString stringWithFormat:@"%ld", (long)rating];
        }
        
        if (capitalized) {
            name = [name capitalizedString];
        }
    } else {
        name = [_ratingNames objectAtIndex:rating];
    }
    
    return name;
}

+ (NSString *)nameForSeason:(FATraktSeason *)season capitalized:(BOOL)capitalized
{
    NSString *name;
    
    if (season.seasonNumber.unsignedIntegerValue == 0) {
        name = @"specials";
    } else {
        name = [NSString stringWithFormat:NSLocalizedString(@"season %i", nil), season.seasonNumber.integerValue];
    }
    
    if (capitalized) {
        name = [name capitalizedString];
    }
    
    return name;
}

+ (NSString *)nameForEpisode:(FATraktEpisode *)episode long:(BOOL)longName capitalized:(BOOL)capitalized
{
    NSString *name;
    
    if (longName) {
        if (episode.seasonNumber.unsignedIntegerValue == 0) {
            if (capitalized) {
                name = [NSString stringWithFormat:NSLocalizedString(@"Specials Episode %i", nil), episode.episodeNumber.unsignedIntegerValue];
            } else {
                name = [NSString stringWithFormat:NSLocalizedString(@"specials episode %i", nil), episode.episodeNumber.unsignedIntegerValue];
            }
        } else {
            if (capitalized) {
                name = [NSString stringWithFormat:NSLocalizedString(@"Season %i Episode %i", nil), episode.seasonNumber.unsignedIntegerValue, episode.episodeNumber.unsignedIntegerValue];
            } else {
                name = [NSString stringWithFormat:NSLocalizedString(@"season %i episode %i", nil), episode.seasonNumber.unsignedIntegerValue, episode.episodeNumber.unsignedIntegerValue];
            }
        }
    } else {
        if (capitalized) {
            name = [NSString stringWithFormat:NSLocalizedString(@"S%02iE%02i", nil), episode.seasonNumber.unsignedIntegerValue, episode.episodeNumber.unsignedIntegerValue];
        } else {
            name = [NSString stringWithFormat:NSLocalizedString(@"s%02ie%02i", nil), episode.seasonNumber.unsignedIntegerValue, episode.episodeNumber.unsignedIntegerValue];
        }
    }
    
    return name;
}

+ (NSString *)progressForProgressValue:(NSInteger)progress totalValue:(NSInteger)total long:(BOOL)longName
{
    NSString *name = nil;
    NSString *progressString;
    NSString *totalString;
    
    if (progress >= 0) {
        progressString = [NSString stringWithFormat:NSLocalizedString(@"%i", nil), progress];
    } else {
        progressString = NSLocalizedString(@"-", nil);
    }
    
    if (total >= 0) {
        totalString = [NSString stringWithFormat:NSLocalizedString(@"%i", nil), total];
    } else {
        totalString = NSLocalizedString(@"-", nil);
    }
    
    if (longName) {
        name = [NSString stringWithFormat:NSLocalizedString(@"Watched %@ / %@", nil), progressString, totalString];
    } else {
        name = [NSString stringWithFormat:NSLocalizedString(@"%@ / %@", nil), progressString, totalString];
    }
    
    return name;
}

+ (NSString *)progressForProgress:(FATraktShowProgress *)progress long:(BOOL)longName
{
    if (progress) {
        return [self progressForProgressValue:progress.completed.unsignedIntegerValue totalValue:progress.completed.unsignedIntegerValue + progress.left.unsignedIntegerValue long:longName];
    } else {
        return [self progressForProgressValue:-1 totalValue:-1 long:longName];
    }
}

+ (NSString *)progressForShow:(FATraktShow *)show long:(BOOL)longName
{
    return [self progressForProgress:show.progress long:longName];
}

+ (NSString *)progressForSeason:(FATraktSeason *)season long:(BOOL)longName
{
    if (season.episodes) {
        return [self progressForProgressValue:season.episodesWatched.unsignedIntegerValue totalValue:season.episodeCount.unsignedIntegerValue long:longName];
    } else {
        return [self progressForProgressValue:-1 totalValue:-1 long:longName];
    }
}

@end
