//
//  FATraktImages.m
//  Zapt
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktImageList.h"
#import "FATraktCache.h"
#import "UIImage+Resize.h"

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

+ (NSString *)imageURLWithURL:(NSString *)urlString forWidth:(NSInteger)width
{
    NSString *suffix = @"";
    
    if (width > 0) {
        if ([urlString containsString:@"/images/poster"]) {
            DDLogController(@"Loading image of type poster");
            
            if (width <= 138) {
                suffix = @"-138";
            } else if (width <= 300) {
                suffix = @"-300";
            }
        } else if ([urlString containsString:@"/images/fanart"] && ![urlString containsString:@"/images/fanart-summary.jpg"]) {
            DDLogController(@"Loading image of type fanart");
            
            if (width <= 218) {
                suffix = @"-218";
            } else if (width <= 940) {
                suffix = @"-940";
            }
        } else {
            suffix = @"";
        }
        
        if ([urlString containsString:@"/images/poster-"]) {
            return nil;
        }
    }
    
    // Remove any suffix if needed, then add suffix
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *extension = [url pathExtension];
    NSURL *urlWithoutExtension = [url URLByDeletingPathExtension];
    NSString *urlStringWithoutExtension = [urlWithoutExtension absoluteString];
    
    NSString *urlStringWithSuffix;
    
    NSString *filename = [urlWithoutExtension lastPathComponent];
    
    if (![filename containsString:@"-138"] &&
        ![filename containsString:@"-300"] &&
        ![filename containsString:@"-218"] &&
        ![filename containsString:@"-940"]) {
        
        urlStringWithSuffix = [urlStringWithoutExtension stringByAppendingString:suffix];
    } else {
        urlStringWithSuffix = urlStringWithoutExtension;
    }
    
    NSURL *urlWithSuffix = [NSURL URLWithString:urlStringWithSuffix];
    return [[urlWithSuffix URLByAppendingPathExtension:extension] absoluteString];
}

- (void)imageWithURL:(NSString *)urlString width:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TMCache *cache = [FATraktCache sharedInstance].images;
        UIImage *image = [UIImage imageWithData:[cache objectForKey:[FATraktImageList imageURLWithURL:urlString forWidth:width]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

- (UIImage *)imageWithURL:(NSString *)urlString width:(NSInteger)width
{
    TMCache *cache = [FATraktCache sharedInstance].images;
    UIImage *image = [UIImage imageWithData:[cache objectForKey:[FATraktImageList imageURLWithURL:urlString forWidth:width]]];
    
    return image;
}

- (UIImage *)posterImageWithWidth:(NSInteger)width
{
    return [self imageWithURL:self.poster width:width];
}

- (UIImage *)fanartImageWithWidth:(NSInteger)width
{
    return [self imageWithURL:self.fanart width:width];
}

- (UIImage *)bannerImageWithWidth:(NSInteger)width
{
    return [self imageWithURL:self.banner width:width];
}

- (UIImage *)screenImageWithWidth:(NSInteger)width
{
    return [self imageWithURL:self.screen width:width];
}

- (void)posterImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self imageWithURL:self.poster width:width callback:callback];
}

- (void)fanartImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self imageWithURL:self.fanart width:width callback:callback];
}

- (void)bannerImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self imageWithURL:self.banner width:width callback:callback];
}

- (void)screenImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *))callback
{
    [self imageWithURL:self.screen width:width callback:callback];
}

@end
