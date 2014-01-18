//
//  FAActivityDispatch.h
//  Zapt
//
//  Created by Finn Wilke on 18.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAUIElementWithActivity.h"

@interface FAActivityDispatch : NSObject

+ (FAActivityDispatch *)sharedInstance;

- (void)registerForAllActivity:(id <FAUIElementWithActivity> )observer;
- (void)registerForActivityName:(NSString *)name observer:(id <FAUIElementWithActivity> )observer;
- (void)unregister:(id <FAUIElementWithActivity> )observer;

- (void)startActivityNamed:(NSString *)name;
- (void)finishActivityNamed:(NSString *)name;
- (void)stopAllNamed:(NSString *)name;

@end
