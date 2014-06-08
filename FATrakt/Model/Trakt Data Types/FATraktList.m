//
//  FATraktList.m
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktList.h"
#import "FATraktListItem.h"
#import "FATraktCache.h"
#import "FATraktContent.h"

@interface FATraktList ()

@end

@implementation FATraktList

- (id)init
{
    self = [super init];
    
    if (self) {
        self.contentType = FATraktContentTypeNone;
        self.libraryType = FATraktLibraryTypeNone;
        self.detailLevel = FATraktDetailLevelMinimal;
    }
    
    return self;
}

- (id)initWithJSONDict:(NSDictionary *)dict
{
    self = [super initWithJSONDict:dict];
    
    if (self) {
        self.contentType = FATraktContentTypeNone;
        self.detailLevel = FATraktDetailLevelMinimal;
        
        /* we don't merge lists. if we do at some point: use this code
        FATraktList *cachedList = [self.class.backingCache objectForKey:self.cacheKey];
        
        if (cachedList && cachedList.detailLevel > self.detailLevel) {
            // cache hit!
            // merge the two
            [cachedList mergeWithObject:self];
            //[cachedShow mapObjectsInDict:dict];
            // return the cached show
            self = cachedList;
        }*/
        
        [self commitToCache];
    }
    
    return self;
}

- (BOOL)containsContent:(FATraktContent *)content
{
    for (FATraktListItem *listItem in self.items) {
        FATraktContent *listContent = listItem.content;
        
        if ([listContent isEqual:content]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addContent:(FATraktContent *)content
{
    FATraktListItem *listItem = [[FATraktListItem alloc] init];
    listItem.content = content;
    
    if (!self.items) {
        self.items = [[NSMutableArray alloc] init];
    }
    
    [self.items addObject:listItem];
}

- (void)removeContent:(FATraktContent *)content
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < self.items.count; i++) {
        FATraktListItem *listItem = [self.items objectAtIndex:i];
        
        if ([listItem.content isEqual:content]) {
            [indexes addIndex:i];
        }
    }
    
    [self.items removeObjectsAtIndexes:indexes];
}

- (void)finishedMappingObjects
{
    /* we don't merge lists. if we do at some point: use this code

    // See if we can find a cached equivalent now and merge them if appropriate
    FATraktList *cachedContent = [self.class.backingCache objectForKey:self.cacheKey];
    
    if (cachedContent && cachedContent != self) {
        if (cachedContent.detailLevel > self.detailLevel) {
            [cachedContent mergeWithObject:self];
            // we don't want to cache this item anymore
            self.shouldBeCached = NO;
        } else {
            [self mergeWithObject:cachedContent];
            [cachedContent removeFromCache];
        }
    }
    
    [self commitToCache];*/
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<FATraktList %p with name \"%@\">", self, self.name];
}

+ (NSString *)cacheKeyForWatchlistWithContentType:(FATraktContentType)contentType
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%li&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%li", @"watchlist", (long)contentType, YES, NO, NO, (long)FATraktLibraryTypeNone];
}

+ (FATraktList *)cachedListForWatchlistWithContentType:(FATraktContentType)contentType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForWatchlistWithContentType:contentType]];
}

+ (NSString *)cacheKeyForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%li&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%li", @"library", (long)contentType, NO, YES, NO, (long)libraryType];
}

+ (FATraktList *)cachedListForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType
{
    return [[FATraktCache sharedInstance].lists objectForKey:[FATraktList cacheKeyForLibraryWithContentType:contentType libraryType:libraryType]];
}

- (NSString *)cacheKey
{
    return [NSString stringWithFormat:@"FATraktList&name=%@&contentType=%li&isWatchlist=%i&isLibrary=%i&isCustom=%i&libraryType=%li", self.name, (long)self.contentType, self.isWatchlist, self.isLibrary, self.isCustom, (long)self.libraryType];
}

+ (NSArray *)cachedCustomLists
{
    NSArray *listCacheKeys = [[FATraktCache sharedInstance].misc objectForKey:@"customListKeys"];
    
    NSMutableArray *customLists = [[NSMutableArray alloc] initWithCapacity:listCacheKeys.count];
    for (id key in listCacheKeys) {
        FATraktContent *content = [self.class.backingCache objectForKey:key];
        
        if (content) {
            [customLists addObject:content];
        }
    }
    
    if (customLists.count == 0) {
        return nil;
    }
    
    return [customLists sortedArrayUsingKey:@"name" ascending:YES];
}

- (void)mergeWithObject:(FATraktDatatype *)object
{
    // Merging lists is inappropriate
    return;
}

+ (TMCache *)backingCache
{
    return FATraktCache.sharedInstance.lists;
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"description"]) {
        [super mapObject:object toPropertyWithKey:@"list_description"];
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:[(NSArray *)object count]];
        
        for (NSDictionary *itemDict in(NSArray *) object) {
            FATraktListItem *item = [[FATraktListItem alloc] initWithJSONDict:itemDict];
            [itemArray addObject:item];
        }
        
        [self setValue:itemArray forKey:key];
    } else if ([key isEqualToString:@"privacy"]) {
        if ([object isEqual:@"public"]) {
            self.privacy = FATraktListPrivacyPublic;
        } else if ([object isEqual:@"friends"]) {
            self.privacy = FATraktListPrivacyFriends;
        } else {
            self.privacy = FATraktListPrivacyPrivate;
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
