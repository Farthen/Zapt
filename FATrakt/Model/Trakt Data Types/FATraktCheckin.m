//
//  FATraktCheckinResponse.m
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCheckin.h"
#import "FATraktMovie.h"
#import "FATraktShow.h"

@interface FATraktCheckin ()

@property (nonatomic) NSString *contentCacheKey;

@end

@implementation FATraktCheckin

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"status"]) {
        if ([object isEqualToString:@"success"]) {
            self.status = FATraktStatusSuccess;
        } else if ([object isEqualToString:@"failure"]) {
            self.status = FATraktStatusFailed;
        } else {
            self.status = FATraktStatusUnkown;
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (void)setContent:(FATraktContent *)content
{
    self.contentCacheKey = content.cacheKey;
}

- (FATraktContent *)content
{
    return [[FATraktContent backingCache] objectForKey:self.contentCacheKey];
}

@end
