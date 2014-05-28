//
//  NSArray+Misc.m
//  Zapt
//
//  Created by Finn Wilke on 26/05/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "NSArray+Misc.h"

@implementation NSArray (Misc)

+ (instancetype)arrayWithObject:(id)object count:(NSUInteger)count
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    if (newArray) {
        [newArray fillArrayToCount:count withObject:object];
    }
    
    return [newArray copy];
}

- (NSArray *)trimmedArrayToCount:(NSUInteger)newCount
{
    NSMutableArray *newArray = [self mutableCopy];
    [newArray trimArrayToCount:newCount];
    
    return [newArray copy];
}

- (NSArray *)filledArrayToCount:(NSUInteger)newCount withObject:(id)newObject
{
    NSMutableArray *newArray = [self mutableCopy];
    [newArray fillArrayToCount:newCount withObject:newObject];
    
    return [newArray copy];
}

@end

@implementation NSMutableArray (Misc)

+ (instancetype)arrayWithObject:(id)object count:(NSUInteger)count
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:count];
    if (newArray) {
        [newArray fillArrayToCount:count withObject:object];
    }
    
    return newArray;
}

- (void)trimArrayToCount:(NSUInteger)newCount
{
    while(self.count > newCount) {
        [self removeObjectAtIndex:self.count - 1];
    }
}

- (void)fillArrayToCount:(NSUInteger)newCount withObject:(id)newObject
{
    while(self.count < newCount)
    {
        [self addObject:newObject];
    }
}

@end