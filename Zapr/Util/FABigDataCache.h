//
//  FABigDataCache.h
//  Zapr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACache.h"

// This is a persistant cache that loads objects directly from a backing store
// Like FACache, this is thread-safe

@interface FABigDataCache : FACache

@property (readonly) NSString *filePath;

@end

@interface FABigDataCachedItem : FACachedItem <NSDiscardableContent>

@property (assign) BOOL dirty;
@property (readonly) NSInteger accessCount;

- (void)commitToPersistentStorage;
- (void)purgeFromPersistentStorage;

@end
