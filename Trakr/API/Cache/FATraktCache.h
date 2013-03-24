//
//  FATraktCache.h
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FACache.h"

@interface FATraktCache : NSObject <NSCoding>

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;
- (BOOL)saveToDisk;
- (BOOL)reloadFromDisk;


@property (readonly) FACache *movies;
@property (readonly) FACache *episodes;
@property (readonly) FACache *shows;
@property (readonly) FACache *images;
@property (readonly) FACache *lists;
@property (readonly) FACache *searches;

@end
