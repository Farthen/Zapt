//
//  NSObject+PerformBlock.h
//  Zapt
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//
// Thanks http://stackoverflow.com/questions/2784809/iphone-nstimer-start-in-2-seconds

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlock)

- (void)performBlock:(void (^)(void))block order:(NSUInteger)order modes:(NSArray *)modes;

- (void)performBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)wait;
- (void)performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait;
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void (^)(void))block repeatCount:(NSUInteger)repeatCount timeInteval:(NSTimeInterval)timeInterval;

@end
