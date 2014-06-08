//
//  UIColor+InvertedColor.m
//  Zapt
//
//  Created by Finn Wilke on 24.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIColor+InvertedColor.h"

@implementation UIColor (InvertedColor)

- (UIColor *)invertedColor
{
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 1;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    red = 1 - red;
    green = 1 - green;
    blue = 1 - blue;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)colorWithHighContrast
{
    UIColor *inverted = [self invertedColor];
    
    // We use the inverted color and increase the contrast by having the color close to black or white
    CGFloat hue = 0, saturation = 0, brightness = 0, alpha = 0;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newHue = 0, newSaturation = 0, newBrightness = 0, newAlpha = 0;
    [inverted getHue:&newHue saturation:&newSaturation brightness:&newBrightness alpha:&newAlpha];
    
    if (brightness > 0.5) {
        // Pick a dark color
        newBrightness = 0.25;
    } else {
        newBrightness = 0.75;
    }
    
    return [UIColor colorWithHue:newHue saturation:newSaturation brightness:newBrightness alpha:newAlpha];
}

@end
