//
//  FATraktSeason.h
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktImageList.h"
#import "FATraktShow.h"

@interface FATraktSeason : FATraktDatatype

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show;

@property (retain) FATraktShow *show;

@property (retain) NSArray *episodes;
@property (retain) FATraktImageList *images;
@property (retain) NSString *poster;
@property (retain) NSNumber *season;
@property (retain) NSString *url;

@end
