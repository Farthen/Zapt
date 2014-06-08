//
//  FATraktCache.h
//  Zapt
//
//  Created by Finn Wilke on 06.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoapods/Cocoapods.h>

extern NSString *FATraktCacheClearedNotification;

@interface FATraktCache : NSObject

+ (FATraktCache *)sharedInstance;
- (void)clearCaches;
- (void)clearCachesCallback:(void (^)(void))callback;

- (void)commitAllCaches;

- (void)migrationRemoveFACache;

@property (readonly) TMCache *misc;
@property (readonly) TMCache *content;
@property (readonly) TMCache *images;
@property (readonly) TMCache *lists;
@property (readonly) TMCache *searches;
@property (readonly) TMCache *calendar;

@end
