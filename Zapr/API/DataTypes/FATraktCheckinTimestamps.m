//
//  FATraktCheckinTimestamps.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktCheckinTimestamps.h"

@implementation FATraktCheckinTimestamps

- (CGFloat)progress
{
    NSTimeInterval total = [self.end timeIntervalSinceDate:self.start];
    NSTimeInterval now = [[NSDate date] timeIntervalSinceDate:self.start];
    
    CGFloat fraction = now / total;
    fraction = MIN(fraction, 1);
    fraction = MAX(fraction, 0);
    
    return fraction;
}

- (NSTimeInterval)remaining
{
    NSDate *now = [NSDate date];
    if ([self.start timeIntervalSinceDate:now] > 0) {
        return [self.end timeIntervalSinceDate:self.start];
    }
    
    return [self.end timeIntervalSinceDate:now];
}

- (BOOL)isOver
{
    NSTimeInterval interval = [self.end timeIntervalSinceNow];
    return interval < 0;
}

@end
