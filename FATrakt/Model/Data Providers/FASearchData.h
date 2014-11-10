//
//  FASearchData.h
//  Zapt
//
//  Created by Finn Wilke on 04.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATraktContent.h"

@interface FASearchData : NSObject <NSCoding>
- (id)initWithSearchString:(NSString *)searchString;

@property (nonatomic) NSString *searchString;

@property (retain) NSArray *movies;
@property (retain) NSArray *shows;
@property (retain) NSArray *episodes;

- (NSArray *)searchDataForContentType:(FATraktContentType)contentType;

@end
