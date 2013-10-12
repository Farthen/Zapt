//
//  FATraktCache.h
//  Zapr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FACache.h"
#import "FABigDataCache.h"

@interface FATraktCache : NSObject <FACacheDelegate, NSCoding>

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;

@property (readonly) FACache *misc;
@property (readonly) FACache *movies;
@property (readonly) FACache *episodes;
@property (readonly) FACache *shows;
@property (readonly) FABigDataCache *images;
@property (readonly) FACache *lists;
@property (readonly) FACache *searches;

@end
