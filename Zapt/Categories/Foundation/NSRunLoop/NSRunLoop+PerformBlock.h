//
//  NSRunLoop+PerformBlock.h
//  Zapt
//
//  Created by Finn Wilke on 14/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRunLoop (PerformBlock)

- (void)performBlock:(void (^)(void))block order:(NSUInteger)order modes:(NSArray *)modes;

@end
