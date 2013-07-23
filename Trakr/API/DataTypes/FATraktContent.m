//
//  FATraktContentType.m
//  Trakr
//
//  Created by Finn Wilke on 07.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktContent.h"
#import "FATraktImageList.h"

#undef LOG_LEVEL
#define LOG_LEVEL LOG_LEVEL_MODEL

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

- (void)mapObject:(id)object ofType:(FAPropertyInfo *)propertyType toPropertyWithKey:(NSString *)key
{
    if ([key isEqualToString:@"images"] && propertyType.objcClass == [FATraktImageList class] && [object isKindOfClass:[NSDictionary class]]) {
        FATraktImageList *imageList = [[FATraktImageList alloc] initWithJSONDict:(NSDictionary *)object];
        [self setValue:imageList forKey:key];
    } else {
        [super mapObject:object ofType:propertyType toPropertyWithKey:key];
    }
}

@end
