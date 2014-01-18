//
//  FATraktCache.h
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FACache.h"
#import "FABigDataCache.h"

extern NSString *FATraktCacheClearedNotification;

@interface FATraktCache : NSObject <FACacheDelegate, NSCoding>

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;

@property (readonly) FACache *misc;
@property (readonly) FACache *content;
@property (readonly) FABigDataCache *images;
@property (readonly) FACache *lists;
@property (readonly) FACache *searches;

@end
