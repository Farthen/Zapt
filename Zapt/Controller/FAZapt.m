//
//  FAZapt.m
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAZapt.h"

@implementation FAZapt

+ (NSString *)applicationName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)versionNumberString
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)buildString
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)versionNumberDescription
{
    NSString *version = [self versionNumberString];
    NSString *build = [self buildString];
    
    NSString *versionBuild = [NSString stringWithFormat:@"v%@", version];
    
    if (![version isEqualToString:build]) {
        versionBuild = [NSString stringWithFormat:@"%@(%@)", versionBuild, build];
    }
    
    return versionBuild;
}

+ (NSDate *)compilationDate
{
    NSString *compilationDateString = [NSString stringWithUTF8String:__DATE__];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d yyyy"];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    return [dateFormatter dateFromString:compilationDateString];
}

@end
