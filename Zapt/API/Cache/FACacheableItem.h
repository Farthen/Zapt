//
//  FACacheableItem.h
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FACache.h"

@protocol FACacheableItem <NSObject>

@required
// the key of the item to be used for the cache
@property (readonly) NSString *cacheKey;
@property BOOL shouldBeCached;

+ (FACache *)backingCache;
- (void)commitToCache;
- (void)removeFromCache;

@end
