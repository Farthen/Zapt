//
//  FATraktContentType.m
//  Zapt
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

#import "FATraktCache.h"

@implementation FATraktContent

- (id)init
{
    self = [super init];
    
    if (self) {
        self.detailLevel = FATraktDetailLevelDefault;
    }
    
    return self;
}

- (void)finishedMappingObjects
{
    // See if we can find a cached equivalent now and merge them if appropriate
    FATraktContent *cachedContent = [self.class.backingCache objectForKey:self.cacheKey];
    
    if (cachedContent && cachedContent != self) {
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
    
    self.shouldBeCached = YES;
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

+ (TMCache *)backingCache
{
    return [FATraktCache sharedInstance].content;
}

- (NSString *)widescreenImageURL
{
    if (self.images.fanart) {
        return self.images.fanart;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return ((FATraktEpisode *)self).show.images.fanart;
    }
    
    return nil;
}

- (NSString *)posterImageURL
{
    if (self.images.poster) {
        return self.images.poster;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return ((FATraktEpisode *)self).show.images.poster;
    }
    
    return nil;
}

- (UIImage *)widescreenImage
{
    if (self.images.fanartImage) {
        return self.images.fanartImage;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return ((FATraktEpisode *)self).show.images.fanartImage;
    }
    
    return nil;
}

- (UIImage *)posterImage
{
    if (self.images.posterImage) {
        return self.images.posterImage;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return ((FATraktEpisode *)self).show.images.posterImage;
    }
    
    return nil;
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
{
    FA_MUST_OVERRIDE_IN_SUBCLASS
    
    return nil;
}

- (NSDictionary *)postDictInfo
{
    FA_MUST_OVERRIDE_IN_SUBCLASS
    
    return nil;
}

- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"rating"]) {
        if ([object isKindOfClass:[NSString class]]) {
            if ([object isEqualToString:@"love"]) {
                if (!self.rating) self.rating = [[FATraktRating alloc] init];
                self.rating.simpleRating = FATraktRatingLove;
            } else if ([object isEqualToString:@"hate"]) {
                if (!self.rating) self.rating = [[FATraktRating alloc] init];
                self.rating.simpleRating = FATraktRatingHate;
            }
        }
    } else if ([key isEqualToString:@"rating_advanced"]) {
        if ([object isKindOfClass:[NSNumber class]]) {
            if ([object integerValue] > 0 && [object integerValue] <= 10) {
                if (!self.rating) self.rating = [[FATraktRating alloc] init];
                self.rating.advancedRating = [object integerValue];
            }
        }
    } else {
        [super mapObject:object toPropertyWithKey:key];
    }
}

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"images"] && propertyType.objcClass == [FATraktImageList class] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktImageList *imageList = [[FATraktImageList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:imageList forKey:key];
    } else  {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

- (id)newValueForMergingKey:(NSString *)key fromOldObject:(id)oldObject
{
    if ([key isEqualToString:@"rating"]) {
        if (self.rating) {
            return self.rating;
        } else {
            return [oldObject rating];
        }
    } else {
        return [super newValueForMergingKey:key fromOldObject:oldObject];
    }
}

@end
