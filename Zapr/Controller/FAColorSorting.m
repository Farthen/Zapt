//
//  FAColorSorting.m
//  Zapr
//
//  Created by Finn Wilke on 23.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAColorSorting.h"

@implementation FAColorSorting

+ (CGFloat)colorLuminance:(UIColor *)color
{
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat luminance = 0.299 * red + 0.587 * green + 0.114 * blue;
    
    return luminance;
}

+ (NSArray *)sortedColorsByLuminanceFromArray:(NSArray *)colorArray ascending:(BOOL)ascending
{
    return [colorArray sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2) {
        UIColor *color1 = obj1;
        UIColor *color2 = obj2;
        
        // http://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
        CGFloat luminance1 = [FAColorSorting colorLuminance:color1];
        CGFloat luminance2 = [FAColorSorting colorLuminance:color2];
        
        if (luminance1 < luminance2) {
            if (ascending) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        } else if (luminance1 > luminance2) {
            if (ascending) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        } else {
            return NSOrderedSame;
        }
    }];
}

@end
