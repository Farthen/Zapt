//
//  FATraktCache.h
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FATraktCache : NSObject

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;

@property (readonly) NSCache *movies;
@property (readonly) NSCache *episodes;
@property (readonly) NSCache *shows;
@property (readonly) NSCache *images;

@end
