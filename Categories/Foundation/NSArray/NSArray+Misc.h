//
//  NSArray+Misc.h
//  Zapt
//
//  Created by Finn Wilke on 26/05/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Misc)

+ (instancetype)arrayWithObject:(id)object count:(NSUInteger)count;
- (NSArray *)trimmedArrayToCount:(NSUInteger)newCount;
- (NSArray *)filledArrayToCount:(NSUInteger)newCount withObject:(id)newObject;

@end

@interface NSMutableArray (Misc)

+ (instancetype)arrayWithObject:(id)object count:(NSUInteger)count;
- (void)trimArrayToCount:(NSUInteger)newCount;
- (void)fillArrayToCount:(NSUInteger)newCount withObject:(id)newObject;

@end
