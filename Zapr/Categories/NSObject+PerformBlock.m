//
//  NSObject+PerformBlock.m
//  Zapr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSObject+PerformBlock.h"

@interface NSObject (PerformBlockHidden)

- (void)performBlock:(void (^)(void))block;

@end

@implementation NSObject (PerformBlock)

- (void)performBlock:(void (^)(void))block
{
    block();
}

- (void)performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait
{
    [self performSelector:@selector(performBlock:) onThread:nil withObject:[block copy] waitUntilDone:wait];
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(performBlock:) withObject:[block copy] afterDelay:delay];
}

- (void)performBlock:(void (^)(void))block repeatCount:(NSUInteger)repeatCount timeInteval:(NSTimeInterval)timeInterval
{
    for (NSUInteger repetition = 0; repetition < repeatCount; repetition++)
        [self performBlock:block afterDelay:(repetition * timeInterval)];
}

@end
