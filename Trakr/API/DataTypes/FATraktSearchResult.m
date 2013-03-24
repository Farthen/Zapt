//
//  FATraktSearchResult.m
//  Trakr
//
//  Created by Finn Wilke on 22.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSearchResult.h"
#import "FATraktCache.h"

@implementation FATraktSearchResult

- (id)initWithQuery:(NSString *)query contentType:(FATraktContentType)contentType
{
    self = [super init];
    if (self) {
        _query = query;
        _contentType = contentType;
    }
    return self;
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktSearchResult&type=%i&query=%@", self.contentType, self.query];
}

- (void)commitToCache
{
    FATraktCache *cache = [FATraktCache sharedInstance];
    [cache.searches setObject:self forKey:self.cacheKey];
}

@end
