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

@property (readonly) UIImage *posterImage;
@property (readonly) UIImage *fanartImage;
@property (readonly) UIImage *bannerImage;
@property (readonly) UIImage *screenImage;

@end
