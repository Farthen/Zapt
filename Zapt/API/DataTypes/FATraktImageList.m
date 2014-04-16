//
//  FATraktImages.m
//  Zapt
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktImageList.h"
#import "FATraktCache.h"

@implementation FATraktImageList

- (NSString *)description
{
    NSMutableDictionary *images = [NSMutableDictionary dictionary];
    
    if (self.poster) {
        images[@"poster"] = self.poster;
    }
    
    if (self.fanart) {
        images[@"fanart"] = self.poster;
    }
    
    if (self.banner) {
        images[@"banner"] = self.poster;
    }
    
    if (self.screen) {
        images[@"screen"] = self.poster;
    }
    
    return [NSString stringWithFormat:@"<FATraktImageList %p with images: %@>", self, images.description];
}

- (UIImage *)posterImage
{
    TMCache *cache = [FATraktCache sharedInstance].images;
    NSData *imageData = nil;
    
    if (self.poster) {
        imageData = [cache objectForKey:[self.poster stringByAppendingFilenameSuffix:@""]];
        
        if (!imageData) {
            imageData = [cache objectForKey:[self.poster stringByAppendingFilenameSuffix:@"-300"]];
        }
        
        if (!imageData) {
            imageData = [cache objectForKey:[self.poster stringByAppendingFilenameSuffix:@"-138"]];
        }
    }
    
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

- (UIImage *)fanartImage
{
    TMCache *cache = [FATraktCache sharedInstance].images;
    NSData *imageData = nil;
    
    if (self.fanart) {
        imageData = [cache objectForKey:[self.fanart stringByAppendingFilenameSuffix:@""]];
        
        if (!imageData) {
            imageData = [cache objectForKey:[self.fanart stringByAppendingFilenameSuffix:@"-940"]];
        }
        
        if (!imageData) {
            imageData = [cache objectForKey:[self.fanart stringByAppendingFilenameSuffix:@"-218"]];
        }
    }
    
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

- (UIImage *)bannerImage
{
    TMCache *cache = [FATraktCache sharedInstance].images;
    NSData *imageData = nil;
    
    if (self.banner) {
        imageData = [cache objectForKey:[self.banner stringByAppendingFilenameSuffix:@""]];
    }
    
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

- (UIImage *)screenImage
{
    TMCache *cache = [FATraktCache sharedInstance].images;
    NSData *imageData = nil;
    
    if (self.screen) {
        imageData = [cache objectForKey:[self.screen stringByAppendingFilenameSuffix:@""]];
    }
    
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    
    
    return nil;
}

- (void)posterImageCallback:(void (^)(UIImage *))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self posterImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

- (void)fanartImageCallback:(void (^)(UIImage *))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self fanartImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

- (void)bannerImageCallback:(void (^)(UIImage *))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self bannerImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

- (void)screenImageCallback:(void (^)(UIImage *))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self screenImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

@end
