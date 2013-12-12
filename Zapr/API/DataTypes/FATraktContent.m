//
//  FATraktContentType.m
//  Zapr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FATraktImageList.h"
#import "FATraktMovie.h"
#import "FATraktShow.h"
#import "FATraktEpisode.h"
#import "FATraktShowProgress.h"
#import "Misc.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_MODEL

@implementation FATraktContent

- (id)init
{
    self = [super init];
    if (self) {
        self.detailLevel = FATraktDetailLevelDefault;
        self.rating = FATraktRatingUndefined;
        self.rating_advanced = FATraktRatingUndefined;
    }
    return self;
}

- (void)finishedMappingObjects
{
    // See if we can find a cached equivalent now and merge them if appropriate
    FATraktContent *cachedContent = [self.class.backingCache objectForKey:self.cacheKey];
    if (cachedContent) {
        if (cachedContent.detailLevel > self.detailLevel) {
            [cachedContent mergeWithObject:self];
            // we don't want to cache this item anymore
            self.shouldBeCached = NO;
            [self removeFromCache];
        } else {
            [self mergeWithObject:cachedContent];
            [cachedContent removeFromCache];
        }
    }
    
    [self commitToCache];
}

- (instancetype)cachedVersion
{
    FATraktContent *cachedVersion = [self.class.backingCache objectForKey:self.cacheKey];
    if (cachedVersion && cachedVersion.detailLevel >= self.detailLevel) {
        [cachedVersion mergeWithObject:self];
        return cachedVersion;
    } else {
        return self;
    }
}

- (NSString *)widescreenImageURL
{
    return self.images.fanart;
}

- (BOOL)isWatched
{
    if ([self isKindOfClass:[FATraktMovie class]]) {
        return ((FATraktMovie *)self).watched;
        
    } else if ([self isKindOfClass:[FATraktShow class]]) {
        
        FATraktShow *show = (FATraktShow *)self;
        if (show.progress) {
            return show.progress.left.unsignedIntegerValue == 0;
        }
        
        return NO;
        
    } else if ([self isKindOfClass:[FATraktEpisode class]]) {
        return ((FATraktEpisode *)self).watched;
        
    }
    
    return NO;
}

- (NSString *)slug
{
    return self.url.lastPathComponent;
}

- (NSString *)urlIdentifier
{ FA_MUST_OVERRIDE_IN_SUBCLASS
    return nil;
}

- (NSDictionary *)postDictInfo
{ FA_MUST_OVERRIDE_IN_SUBCLASS
    return nil;
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"images"] && propertyType.objcClass == [FATraktImageList class] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktImageList *imageList = [[FATraktImageList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:imageList forKey:key];
    } else if ([key isEqualToString:@"rating"]) {
        if ([object isKindOfClass:[NSString class]]) {
            if ([object isEqualToString:@"love"]) {
                self.rating = FATraktRatingLove;
            } else if ([object isEqualToString:@"hate"]) {
                self.rating = FATraktRatingHate;
            }
        }
    } else if ([key isEqualToString:@"rating_advanced"]) {
        if ([object isKindOfClass:[NSNumber class]]) {
            if ([object integerValue] > 0 && [object integerValue] <= 10) {
                self.rating_advanced = [object integerValue];
            }
        }
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
