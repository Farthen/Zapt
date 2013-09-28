//
//  FAColorCompositing.m
//  Zapr
//
//  Created by Finn Wilke on 21.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAColorCompositing.h"

@implementation FAColorCompositing

+ (UIImage *)imageWithHorizontallyStripedColorsFromArray:(NSArray *)colorArray size:(CGSize)size
{
    return [self imageWithStripedColorsFromArray:colorArray size:size orientation:FAColorCompositingOrientationHorizontal insets:UIEdgeInsetsZero];
}

+ (UIImage *)imageWithStripedColorsFromArray:(NSArray *)colorArray size:(CGSize)size orientation:(FAColorCompositingOrientation)orientation insets:(UIEdgeInsets)insets
{
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat segmentLength;
    if (orientation == FAColorCompositingOrientationHorizontal) {
        segmentLength = (size.height - insets.top - insets.bottom) / colorArray.count;
    } else {
        segmentLength = (size.width - insets.left - insets.right) / colorArray.count;
    }
    CGRect sizeRect;
    sizeRect.size = size;
    sizeRect.origin.x = 0;
    sizeRect.origin.y = 0;
    
    for (NSUInteger i = 0; i < colorArray.count; i++) {
        UIColor *color = [colorArray objectAtIndex:i];
        [color set];
        CGRect rect = sizeRect;
        
        if (orientation == FAColorCompositingOrientationHorizontal) {
            if (i == 0) {
                rect.size.height = segmentLength + insets.top;
                rect.origin.y = 0;
            } else {
                if (i == colorArray.count - 1) {
                    rect.size.height = segmentLength + insets.bottom;
                } else {
                    rect.size.height = segmentLength;
                }
                rect.origin.y = i * segmentLength + insets.top;
            }
        } else {
            if (i == 0) {
                rect.size.width = segmentLength + insets.left;
                rect.origin.x = 0;
            } else {
                if (i == colorArray.count - 1) {
                    rect.size.width = segmentLength + insets.right;
                } else {
                    rect.size.width = segmentLength;
                }
                rect.origin.x = i * segmentLength + insets.left;
            }
        }
        CGContextFillRect(ctx, rect);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// http://stackoverflow.com/questions/5825149/overlay-blend-mode-formula
+ (UIColor *)colorByCompositingColor:(UIColor *)topColor onTopOf:(UIColor *)bottomColor
{
    CGFloat newComponents[4];
    const CGFloat *topComponents = CGColorGetComponents(topColor.CGColor);
    const CGFloat *components = CGColorGetComponents(bottomColor.CGColor);
    const int n = CGColorGetNumberOfComponents(bottomColor.CGColor);
    
    for(int i=0; i < n; i++) {
        
        if(components[i] > 0.5) {
            CGFloat value = (topComponents[i]-components[i])/0.5;
            CGFloat min = components[i]-(topComponents[i]-components[i]);
            newComponents[i] = topComponents[i]*value+min;
        } else {
            CGFloat value = components[i]/0.5;
            newComponents[i] = topComponents[i]*value;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace, newComponents);
    UIColor *resultColor = [UIColor colorWithCGColor:colorRef];
    CGColorRelease(colorRef);
    CGColorSpaceRelease(colorSpace);
    
    return resultColor;
}

+ (UIColor *)colorByMultiplyingSaturationOfColor:(UIColor *)color withFactor:(CGFloat)factor
{
    factor = MIN(factor, 1);
    factor = MAX(factor, 0);
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    red = red * factor;
    green = green * factor;
    blue = blue * factor;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
