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
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%i", @"watchlist", contentType, YES, NO, NO, FATraktLibraryTypeNone];
}

+ (FATraktList *)cachedListForWatchlistWithContentType:(FATraktContentType)contentType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForWatchlistWithContentType:contentType]];
}

+ (NSString *)cacheKeyForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%i", @"library", contentType, NO, YES, NO, libraryType];
}

+ (FATraktList *)cachedListForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForLibraryWithContentType:contentType libraryType:libraryType]];
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%i&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%i", self.name, self.contentType, self.isWatchlist, self.isLibrary, self.isCustom, self.libraryType];
}

+ (NSArray *)cachedCustomLists
{
    NSArray *allLists = [self.class.backingCache allObjects];
    NSMutableArray *customLists = [[NSMutableArray alloc] initWithCapacity:allLists.count];
    for (FATraktList *list in allLists) {
        if (list.isCustom) {
            [customLists addObject:list];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [customLists sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

+ (FACache *)backingCache
{
    return FATraktCache.sharedInstance.lists;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        for (NSDictionary *itemDict in (NSArray *)object) {
            FATraktListItem *item = [[FATraktListItem alloc] initWithJSONDict:itemDict];
            [itemArray addObject:item];
        }
        [self setValue:[NSArray arrayWithArray:itemArray] forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
