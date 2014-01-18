//
//  FATraktListItem.m
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktListItem.h"
#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktSeason.h"

#import "FATraktCache.h"

@implementation FATraktListItem {
    id <FACacheableItem> _content;
    NSString *_contentCacheKey;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktListItem %p of type \"%@\">", self, [self.content className]];
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"movie"]) {
        _content = [[FATraktMovie alloc] initWithJSONDict:object];
    } else if ([key isEqualToString:@"season"]) {
        _content = [[FATraktSeason alloc] initWithJSONDict:object];
    } else if ([key isEqualToString:@"show"]) {
        _content = [[FATraktShow alloc] initWithJSONDict:object];
    } else if ([key isEqualToString:@"episode"]) {
        _content = [[FATraktEpisode alloc] initWithJSONDict:object];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (NSSet *)notEncodableKeys
{
    return [NSSet setWithObject:@"content"];
}

- (void)setContent:(FATraktContent *)content
{
    _content = content;
}

- (FATraktContent *)content
{
    if (!_content) {
        _content = [[FATraktCache sharedInstance].content objectForKey:self.contentCacheKey];
    }
    
    if ([_content isKindOfClass:[FATraktSeason class]]) {
        return nil;
    }
    
    return (FATraktContent *)_content;
}

- (void)setContentCacheKey:(NSString *)contentCacheKey
{
    _contentCacheKey = contentCacheKey;
}

- (NSString *)contentCacheKey
{
    if (_content) {
        return _content.cacheKey;
    }
    
    return _contentCacheKey;
}

- (FATraktMovie *)movie
{
    if ([self.content isKindOfClass:[FATraktMovie class]]) {
        return (FATraktMovie *)self.content;
    }
    
    return nil;
}

- (FATraktShow *)show
{
    if ([self.content isKindOfClass:[FATraktShow class]]) {
        return (FATraktShow *)self.content;
    }
    
    return nil;
}

- (FATraktSeason *)season
{
    if ([self.content isKindOfClass:[FATraktSeason class]]) {
        return (FATraktSeason *)self.content;
    }
    
    return nil;
}

- (FATraktEpisode *)episode
{
    if ([self.content isKindOfClass:[FATraktEpisode class]]) {
        return (FATraktEpisode *)self.content;
    }
    
    return nil;
}

@end
