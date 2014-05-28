//
//  NSRunLoop+PerformBlock.m
//  Zapt
//
//  Created by Finn Wilke on 14/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "NSRunLoop+PerformBlock.h"

@implementation NSRunLoop (PerformBlock)

- (void)performBlock:(void (^)(void))block
{
    block();
}

- (void)performBlock:(void (^)(void))block order:(NSUInteger)order modes:(NSArray *)modes
{
    [self performSelector:@selector(performBlock:) target:self argument:[block copy] order:order modes:modes];
}

@end
