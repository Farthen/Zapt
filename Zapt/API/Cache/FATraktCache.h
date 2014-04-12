//
//  FATraktCache.h
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCache.h"

extern NSString *FATraktCacheClearedNotification;

@interface FATraktCache : NSObject <NSCoding>

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;

@property (readonly) TMCache *misc;
@property (readonly) TMCache *content;
@property (readonly) TMCache *images;
@property (readonly) TMCache *lists;
@property (readonly) TMCache *searches;

@end
