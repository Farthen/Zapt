//
//  FATraktAccountSettings.m
//  Zapt
//
//  Created by Finn Wilke on 06.08.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktAccountSettings.h"
#import "FATraktViewingSettings.h"
#import "FATraktCache.h"

@implementation FATraktAccountSettings

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.success = NO;
    }
    
    return self;
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktAccountSettings"];
}

+ (FACache *)backingCache
{
    return [FATraktCache sharedInstance].misc;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"status"]) {
        if ([object isKindOfClass:[NSString class]]) {
            if ([object isEqualToString:@"success"]) {
                self.success = YES;
            }
        }
    } else if ([key isEqualToString:@"viewing"]) {
        FATraktViewingSettings *viewingSettings = [[FATraktViewingSettings alloc] initWithJSONDict:object];
        self.viewing = viewingSettings;
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (void)mergeWithObject:(FATraktDatatype *)object
{
    // Settings can't be merged
    return;
}

@end
