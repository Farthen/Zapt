//
//  FATraktImages.h
//  Zapt
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@interface FATraktImageList : FATraktDatatype

@property (retain) NSString *poster;
@property (retain) NSString *fanart;
@property (retain) NSString *banner;
@property (retain) NSString *screen;

- (UIImage *)posterImageWithWidth:(NSInteger)width;
- (UIImage *)fanartImageWithWidth:(NSInteger)width;
- (UIImage *)bannerImageWithWidth:(NSInteger)width;
- (UIImage *)screenImageWithWidth:(NSInteger)width;

- (void)posterImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback;
- (void)fanartImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback;
- (void)bannerImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback;
- (void)screenImageWithWidth:(NSInteger)width callback:(void (^)(UIImage *image))callback;

+ (NSString *)imageURLWithURL:(NSString *)urlString forWidth:(NSInteger)width;

@end
