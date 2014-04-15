//
//  FATraktCachedDatatype.h
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FACacheableItem.h"

@interface FATraktCachedDatatype : FATraktDatatype <FACacheableItem>

+ (instancetype)objectWithCacheKey:(NSString *)cacheKey;

@property BOOL shouldBeCached;
- (instancetype)cachedVersion;

@end
