//
//  FADominantColorsAnalyzer.m
//  Zapr
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

// Code ported (stolen) from http://charlesleifer.com/blog/using-python-and-k-means-to-find-the-dominant-colors-in-images/

#import "FADominantColorsAnalyzer.h"
#import <ctype.h>
#import "UIImage+Resize.h"
#import <CoreGraphics/CoreGraphics.h>

struct Color {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t alpha;
} __attribute__ ((packed));
typedef struct Color Color;

// This is the same size as color. We are doing fun stuff here :)
struct ColorValue {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    uint8_t clusterIndex;
} __attribute__ ((packed));
typedef struct ColorValue ColorValue;

struct ColorValueCollection {
    ColorValue *values;
    NSUInteger count;
};
typedef struct ColorValueCollection ColorValueCollection;

struct ColorCluster {
    ColorValue center;
};
typedef struct ColorCluster ColorCluster;

struct ClusterCalculationValues {
    NSUInteger red;
    NSUInteger green;
    NSUInteger blue;
    NSUInteger count;
};
typedef struct ClusterCalculationValues ClusterCalculationValues;

@implementation FADominantColorsAnalyzer

// modified from http://stackoverflow.com/a/1262893/1084385

// This function returns ColorValueCollection
// Remember to free ->values after usage!
ColorValueCollection colorArrayFromImage(UIImage *image)
{
    // Make the image smaller if needed
    if (image.size.width * image.size.height > 102400) {
        image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(320, 320) interpolationQuality:kCGInterpolationLow];
    }
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger pixelCount = height * width;
    NSUInteger bytesPerPixel = sizeof(Color);
    NSUInteger bitsPerColorComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    Color *colorData = calloc(pixelCount, bytesPerPixel);
    CGContextRef context = CGBitmapContextCreate(colorData, width, height, bitsPerColorComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    
    // Just cast it and we are done
    ColorValue *value = (ColorValue *)colorData;
    ColorValueCollection collection;
    collection.values = value;
    collection.count = pixelCount;
    return collection;
}

static CGFloat euclideanDistance(ColorValue *value1, ColorValue *value2)
{
    CGFloat x = (CGFloat)(value1->red) - (CGFloat)(value2->red);
    CGFloat y = (CGFloat)(value1->green) - (CGFloat)(value2->green);
    CGFloat z = (CGFloat)(value1->blue) - (CGFloat)(value2->blue);
    CGFloat distance = sqrt(x*x + y*y + z*z);
    return distance;
}

static NSUInteger recalculateCenters(ColorCluster *clusters, NSUInteger clusterCount, ColorValueCollection *valueCollection)
{
    // Returns the max difference of the centers.
    // This is fun! (not)
    
    ColorValue *values = valueCollection->values;
    NSUInteger valueCount = valueCollection->count;
    
    // Stack allocate an array of ClusterCalculationValues
    ClusterCalculationValues clusterValues[clusterCount];
    
    // clear all memory allocated on stack, we want zeroes everywhere, please :)
    memset(&clusterValues, 0, sizeof(clusterValues));
    
    for (NSUInteger i = 0; i < valueCount; i++) {
        ColorValue *value = &values[i];
        
        // Check the cluster index
        uint8_t clusterIndex = value->clusterIndex;
        
        clusterValues[clusterIndex].red += value->red;
        clusterValues[clusterIndex].green += value->green;
        clusterValues[clusterIndex].blue += value->blue;
        clusterValues[clusterIndex].count += 1;
    }
    
    // This is an Integer division and we are perfectly fine with this.
    // It also shouldn't consume more than a uint8_t, this is RGB after all.
    
    NSUInteger distance = 0;
    for (NSUInteger i = 0; i < clusterCount; i++) {
        ColorCluster *cluster = &clusters[i];
        ClusterCalculationValues *value = &clusterValues[i];
        
        if (value->count > 1) {
            ColorValue oldCenter = cluster->center;
            cluster->center.red = value->red / value->count;
            cluster->center.green = value->green / value->count;
            cluster->center.blue = value->blue / value->count;
            distance = MAX(distance, euclideanDistance(&oldCenter, &cluster->center));
        } else {
            distance = NSUIntegerMax;
        }
    }
    
    return distance;
}

static ColorCluster *colorClusters(ColorValueCollection *valueCollection, NSUInteger clusterCount, CGFloat smallestDistanceLimit)
{
    ColorCluster *clusters = calloc(sizeof(ColorCluster), clusterCount);
    // Pick clusterCount * random points in the value array
    NSUInteger currentValue = 0;
    for (NSUInteger i = 0; i < clusterCount; i++) {
        ColorCluster *currentCluster = &clusters[i];
        
        // The original algorithm just picks some values at random. We actually want to get those
        // more deterministically. In particular we don't want duplicate values whenever possible
        // We just pick the first different values 1 - n and work from that (except when this is exceeding the value array)
        NSUInteger index;
        BOOL close = NO;
        do {
            close = NO;
            index = MIN(valueCollection->count, currentValue);;
            currentValue++;
            
            // Iterate over all the old clusters
            // Check if they are the same
            for (NSUInteger j = 0; j < i; j++) {
                ColorCluster *oldCluster = &clusters[j];
                // Check the differences of the colors to get some variation in the start clusters
                NSInteger diffRed = oldCluster->center.red - valueCollection->values[index].red;
                NSInteger diffGreen = oldCluster->center.green - valueCollection->values[index].green;
                NSInteger diffBlue = oldCluster->center.blue - valueCollection->values[index].blue;
                if (diffRed != 0 || diffGreen != 0 || diffBlue != 0) {
                    close = NO;
                } else {
                    close = YES;
                }
            }
        } while (close && currentValue < valueCollection->count);
        
        // Copies over the center, it is not part of the collection and will be removed later
        currentCluster->center = valueCollection->values[index];
        currentCluster->center.clusterIndex = i;
        
        valueCollection->values[index].clusterIndex = i;
    }
    
    ColorValue *values = valueCollection->values;
    
    CGFloat distance;
    
    do {
        // Find the nearest cluster for all points
        for (NSUInteger i = 0; i < valueCollection->count; i++) {
            ColorValue *value = &values[i];
            CGFloat smallestDistance = CGFLOAT_MAX;
            for (NSUInteger j = 0; j < clusterCount; j++) {
                ColorCluster *currentCluster = &clusters[j];
                CGFloat distance = euclideanDistance(value, &currentCluster->center);
                if (distance < smallestDistance) {
                    smallestDistance = distance;
                    value->clusterIndex = j;
                }
            }
        }
        
        distance = recalculateCenters(clusters, clusterCount, valueCollection);
        
    } while (distance > smallestDistanceLimit);
    
    return clusters;
}

// Returns an NSArray of UIColors
+ (NSArray *)dominantColorsOfImage:(UIImage *)image sampleCount:(NSUInteger)count
{
    ColorValueCollection currentColorValueCollection = colorArrayFromImage(image);
    ColorCluster *clusters = colorClusters(&currentColorValueCollection, count, 1);
    
    // We don't need the colorValues anymore
    free(currentColorValueCollection.values);
    
    // We still have the clusters and the center points.
    // Create UIColor objects for those
    NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        ColorValue currentColor = clusters[i].center;
        CGFloat red = (CGFloat)currentColor.red / 0xff;
        CGFloat green = (CGFloat)currentColor.green / 0xff;
        CGFloat blue = (CGFloat)currentColor.blue / 0xff;
        UIColor *colorObj = [UIColor colorWithRed:red green:green blue:blue alpha:1];
        [colorArray addObject:colorObj];
    }
        
    // Now free the clusters too
    free(clusters);
    
    return colorArray;
}

@end
