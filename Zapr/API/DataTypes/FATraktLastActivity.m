//
//  FATraktLastActivity.m
//  Zapr
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktLastActivity.h"
#import "FATraktCache.h"

@implementation FATraktLastActivity

- (NSSet *)changedPathsForDictA:(NSDictionary *)dictA dictB:(NSDictionary *)dictB name:(NSString *)name
{
    NSMutableSet *changedPaths = [NSMutableSet set];
    
    for (NSString *key in dictA) {
        NSNumber *myNumber = [dictA objectForKey:key];
        NSUInteger myTimestamp = myNumber.unsignedIntegerValue;
        
        NSNumber *theirNumber = [dictB objectForKey:key];
        NSUInteger theirTimestamp = 0;
        
        if (theirNumber) {
            theirTimestamp = theirNumber.unsignedIntegerValue;
        }
        
        if (myTimestamp != theirTimestamp || !dictB) {
            [changedPaths addObject:[NSString stringWithFormat:@"%@.%@", name, key]];
        }
    }
    
    return changedPaths;
}

- (NSSet *)changedPathsToActivity:(FATraktLastActivity *)otherActivity
{
    if (otherActivity.all.unsignedIntegerValue == self.all.unsignedIntegerValue) {
        return nil;
    } else {
        NSMutableSet *changedPaths = [NSMutableSet set];
        [changedPaths unionSet:[self changedPathsForDictA:self.movie dictB:otherActivity.movie name:@"movie"]];
        [changedPaths unionSet:[self changedPathsForDictA:self.show dictB:otherActivity.show name:@"show"]];
        [changedPaths unionSet:[self changedPathsForDictA:self.episode dictB:otherActivity.episode name:@"episode"]];
        
        return changedPaths;
    }
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktLastActivity"];
}

+ (FACache *)backingCache
{
    return [FATraktCache sharedInstance].misc;
}

- (void)mergeWithObject:(FATraktDatatype *)object
{
    // Last activities can't be merged
    return;
}

@end
