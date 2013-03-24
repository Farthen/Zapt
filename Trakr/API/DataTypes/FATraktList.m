//
//  FATraktList.m
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FATraktCache.h"
#import "FATraktContent.h"

@implementation FATraktList

- (id)init
{
    self = [super init];
    if (self) {
        self.contentType = FATraktContentTypeNone;
        self.libraryType = FATraktLibraryTypeNone;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktList %p with name \"%@\">", self, self.name];
}

+ (NSString *)cacheKeyForWatchlistWithContentType:(FATraktContentType)contentType
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&libraryType=%i", @"watchlist", contentType, YES, NO, FATraktLibraryTypeNone];
}

+ (FATraktList *)cachedListForWatchlistWithContentType:(FATraktContentType)contentType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForWatchlistWithContentType:contentType]];
}

+ (NSString *)cacheKeyForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&libraryType=%i", @"library", contentType, NO, YES, libraryType];
}

+ (FATraktList *)cachedListForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForLibraryWithContentType:contentType libraryType:libraryType]];
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&libraryType=%i", self.name, self.contentType, self.isWatchlist, self.isLibrary, self.libraryType];
}

- (void)commitToCache
{
    FATraktCache *cache = [FATraktCache sharedInstance];
    [cache.lists setObject:self forKey:self.cacheKey];
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *itemDict in (NSArray *)object) {
            FATraktListItem *item = [[FATraktListItem alloc] initWithJSONDict:object];
            [itemArray addObject:item];
        }
        [self setValue:[NSArray arrayWithArray:itemArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
