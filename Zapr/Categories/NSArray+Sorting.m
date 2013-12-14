//
//  NSArray+Sorting.m
//  Zapr
//
//  Created by Finn Wilke on 23.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "NSArray+Sorting.h"

@implementation NSArray (Sorting)

- (instancetype)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

@end
