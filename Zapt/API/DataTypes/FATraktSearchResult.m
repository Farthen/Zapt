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
    NSArray *_results;
}

- (id)initWithQuery:(NSString *)query contentType:(FATraktContentType)contentType
{
    self = [super init];
    
    if (self) {
        _query = query;
        _contentType = contentType;
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
    _results = results;
}

- (NSArray *)results
{
    if (!_results) {
        _results = [_resultCacheKeys mapUsingBlock:^id (id obj, NSUInteger idx) {
            return [self.class.backingCache objectForKey:obj];
        }];
    }
    
    return _results;
}

- (void)setResultCacheKeys:(NSArray *)resultCacheKeys
{
    _resultCacheKeys = resultCacheKeys;
}

- (NSArray *)resultCacheKeys
{
    if (self.results) {
        return [self.results valueForKey:@"cacheKey"];
    }
    
    return _resultCacheKeys;
}

@end
