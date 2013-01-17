//
//  FATraktImages.h
//  Trakr
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@interface FATraktImageList : FATraktDatatype

@property (retain) NSString *poster;
@property (retain) NSString *fanart;
@property (retain) NSString *banner;

@end
