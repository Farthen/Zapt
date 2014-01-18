//
//  FAColorSorting.h
//  Zapt
//
//  Created by Finn Wilke on 23.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAColorSorting : NSObject

+ (CGFloat)colorLuminance:(UIColor *)color;
+ (NSArray *)sortedColorsByLuminanceFromArray:(NSArray *)array ascending:(BOOL)ascending;

@end
