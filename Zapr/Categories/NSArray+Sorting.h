//
//  NSArray+Sorting.h
//  Trakr
//
//  Created by Finn Wilke on 23.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Sorting)

- (instancetype)sortedArrayUsingKey:(NSString *)key ascending:(BOOL)ascending;

@end
