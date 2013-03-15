//
//  FATraktList.h
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FACacheableItem.h"

@interface FATraktList : FATraktDatatype <FACacheableItem>

@property (retain) NSString *name;
@property (retain) NSString *slug;
@property (retain) NSString *url;
//@property (retain) NSString *description;
@property (retain) NSString *privacy;
@property (assign) BOOL show_numbers;
@property (assign) BOOL allow_shouts;
@property (retain) NSArray *items;

@property (assign) BOOL isWatchlist;
@end
