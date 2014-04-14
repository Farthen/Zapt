//
//  FATraktSearchResult.m
//  Zapt
//
//  Created by Finn Wilke on 22.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktSearchResult.h"
#import "FATraktCache.h"

@implementation FATraktSearchResult {
    NSArray *_resultCacheKeys;
}

- (id)initWithQuery:(NSString *)query contentType:(FATraktContentType)contentType
{
    self = [super init];
    
    if (self) {
        _query = query;
        _contentType = contentType;
        
        FATraktSearchResult *oldResult = [self cachedVersion];
        
        if (oldResult) {
            // Rather update the results of an old object than make a new one
            self = oldResult;
        }
    }
    
    return self;
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObject:@"results"];
}

+ (TMCache *)backingCache
{
    return FATraktCache.sharedInstance.searches;
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktSearchResult&type=%li&query=%@", (long)self.contentType, self.query];
}

- (void)setResults:(NSArray *)results
{
    _resultCacheKeys = [results mapUsingBlock:^id(id obj, NSUInteger idx) {
        return [obj cacheKey];
    }];
}

- (NSArray *)results
{
    return [_resultCacheKeys mapUsingBlock:^id (id obj, NSUInteger idx) {
        return [[FATraktContent backingCache] objectForKey:obj];
    }];
}

- (void)setResultCacheKeys:(NSArray *)resultCacheKeys
{
    _resultCacheKeys = resultCacheKeys;
}

- (NSArray *)resultCacheKeys
{
    return _resultCacheKeys;
}

@end
