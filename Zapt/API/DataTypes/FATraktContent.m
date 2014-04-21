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

- (UIImage *)widescreenImageWithWidth:(NSInteger)width
{
    UIImage *fanartImage = [self.images fanartImageWithWidth:width];
    
    if (fanartImage) {
        return fanartImage;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return [((FATraktEpisode *)self).show.images fanartImageWithWidth:width];
    }
    
    return nil;
}

- (UIImage *)posterImageWithWidth:(NSInteger)width
{
    UIImage *posterImage = [self.images posterImageWithWidth:width];

    if (posterImage) {
        return posterImage;
    }
    
    if (self.contentType == FATraktContentTypeEpisodes) {
        return [((FATraktEpisode *)self).show.images posterImageWithWidth:width];
    }
    
    return nil;
}

- (void)widescreenImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self.images fanartImageWithWidth:width callback:^(UIImage *image) {
        if (image) {
            callback(image);
            return;
        }
        
        if (self.contentType == FATraktContentTypeEpisodes) {
            [((FATraktEpisode *)self).show.images fanartImageWithWidth:width callback:^(UIImage *image) {
                callback(image);
            }];
            
            return;
        }
        
        callback(nil);
        return;
    }];
}

- (void)posterImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self.images posterImageWithWidth:width callback:^(UIImage *image) {
        if (image) {
            callback(image);
            return;
        }
        
        if (self.contentType == FATraktContentTypeEpisodes) {
            [((FATraktEpisode *)self).show.images posterImageWithWidth:width callback:^(UIImage *image) {
                callback(image);
            }];
            
            return;
        }
        
        callback(nil);
        return;
    }];
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

@end
