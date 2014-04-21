//
//  TMFastCache.h
//  Zapt
//
//  Created by Finn Wilke on 15/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "TMCache.h"

@interface TMFastCache : TMCache

// Call this method when the application goes to background
- (void)commitAllObjects;

@end
