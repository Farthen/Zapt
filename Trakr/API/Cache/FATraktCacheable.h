//
//  FATraktCacheable.h
//  Trakr
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FATraktCacheable <NSObject>

@required
// the key of the item to be used for the cache
@property (readonly) NSString *cacheKey;

@end
