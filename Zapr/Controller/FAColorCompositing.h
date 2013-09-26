//
//  FAColorCompositing.h
//  Zapr
//
//  Created by Finn Wilke on 21.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FAColorCompositingOrientation {
    FAColorCompositingOrientationHorizontal,
    FAColorCompositingOrientationVertical
};
typedef enum FAColorCompositingOrientation FAColorCompositingOrientation;

@interface FAColorCompositing : NSObject

+ (UIImage *)imageWithHorizontallyStripedColorsFromArray:(NSArray *)colorArray size:(CGSize)size;
+ (UIImage *)imageWithStripedColorsFromArray:(NSArray *)colorArray size:(CGSize)size orientation:(FAColorCompositingOrientation)orientation insets:(UIEdgeInsets)insets;

+ (UIColor *)colorByCompositingColor:(UIColor *)topColor onTopOf:(UIColor *)bottomColor;
+ (UIColor *)colorByMultiplyingSaturationOfColor:(UIColor *)color withFactor:(CGFloat)factor;

@end
