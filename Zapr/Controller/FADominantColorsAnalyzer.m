//
//  FADominantColorsAnalyzer.m
//  Zapr
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

// Code ported (stolen) from http://charlesleifer.com/blog/using-python-and-k-means-to-find-the-dominant-colors-in-images/

#import "FADominantColorsAnalyzer.h"

struct color {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
};
typedef struct color color;

struct colorCluster;
struct colorValue {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    NSUInteger count;
    struct colorCluster *cluster;
};
typedef struct colorValue colorValue;

struct colorValueCollection {
    colorValue *values;
    NSUInteger count;
};
typedef struct colorValueCollection colorValueCollection;

struct colorCluster {
    colorValue center;
};
typedef struct colorCluster colorCluster;

@implementation FADominantColorsAnalyzer

// modified from http://stackoverflow.com/a/1262893/1084385

// This function returns _FADominantColorsAnalyzerColorValue
// Remember to free it and ->values after usage!
colorValueCollection *colorArrayFromImage(UIImage *image)
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger pixelCount = height * width;
    NSUInteger bytesPerPixel = sizeof(color);
    NSUInteger bitsPerColorComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    color *colorData = calloc(pixelCount, bytesPerPixel);
    CGContextRef context = CGBitmapContextCreate(colorData, width, height, bitsPerColorComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    
    // Create an array to hold the results
    NSUInteger bytesPerColorValue = sizeof(colorValue);
    colorValue *valueData = calloc(pixelCount, bytesPerColorValue);
    NSUInteger valueDataCount = 0;
    
    for (NSUInteger i = 0 ; i < pixelCount ; i++)
    {
        BOOL found = NO;
        color *currentColor = &colorData[i];
        for (NSUInteger j = 0; j < valueDataCount; j++) {
            colorValue *comparisonColorValue = &valueData[j];
            if (comparisonColorValue->red == currentColor->red &&
                comparisonColorValue->green == currentColor->green &&
                comparisonColorValue->blue == currentColor->blue) {
                
                comparisonColorValue->count += 1;
                comparisonColorValue->cluster = NULL;
                found = YES;
                break;
            }
        }
        if (!found) {
            // Select the next color value
            colorValue *currentColorValue = &valueData[valueDataCount];
            currentColorValue->red = currentColor->red;
            currentColorValue->green = currentColor->green;
            currentColorValue->blue = currentColor->blue;
            currentColorValue->count = 1;
            valueDataCount += 1;
        }
    }
    
    colorValueCollection *collection = calloc(sizeof(colorValueCollection), 1);
    collection->values = valueData;
    collection->count = valueDataCount;
    
    // We have copied over all color data, we can free it now.
    free(colorData);
    return collection;
}

static CGFloat euclideanDistance(colorValue *value1, colorValue *value2)
{
    CGFloat x = (CGFloat)(value1->red) - (CGFloat)(value2->red);
    CGFloat y = (CGFloat)(value1->green) - (CGFloat)(value2->green);
    CGFloat z = (CGFloat)(value1->blue) - (CGFloat)(value2->blue);
    CGFloat distance = sqrt(x*x + y*y + z*z);
    return distance;
}

static void recalculateCenter(colorCluster *cluster, colorValueCollection *valueCollection)
{
    // Returns the colorValue that is closest to the center.
    // This is fun!
    
    colorValue *values = valueCollection->values;
    NSUInteger valueCount = valueCollection->count;
    
    // First create the center point
    NSUInteger pointCount = 0;
    NSUInteger redValue = 0;
    NSUInteger greenValue = 0;
    NSUInteger blueValue = 0;
    for (NSUInteger i = 0; i < valueCount; i++) {
        colorValue *value = &values[i];
        
        // Check if it is member of the current cluster
        if (value->cluster == cluster) {
            NSUInteger count = value->count;
            pointCount += count;
            redValue += value->red * count;
            greenValue += value->green * count;
            blueValue += value->blue * count;
        }
    }
    
    // This is an Integer division and we are perfectly fine with this.
    // It also shouldn't consume more than a char, this is RGB after all.
    
    cluster->center.red = redValue / pointCount;
    cluster->center.green = greenValue / pointCount;
    cluster->center.blue = blueValue / pointCount;
}

static colorCluster *colorClusters(colorValueCollection *valueCollection, NSUInteger clusterCount, CGFloat smallestDistanceLimit)
{
    colorCluster *clusters = calloc(sizeof(colorCluster), clusterCount);
    // Pick clusterCount * random points in the value array
    for (NSUInteger i = 0; i < clusterCount; i++) {
        colorCluster *currentCluster = &clusters[i];
        
        // The original algorithm just picks some values at random. We actually want to get those
        // more deterministically. In particular we don't want duplicate values whenever possible
        // We just pick the values 1 - n and work from that (except when this is exceeding the value array)
        
        NSUInteger index = MIN(valueCollection->count, i);
        
        // Copies over the center, it is not part of the collection and will be removed later
        currentCluster->center = valueCollection->values[index];
        currentCluster->center.count = 0;
        currentCluster->center.cluster = currentCluster;
        
        valueCollection->values[index].cluster = currentCluster;
    }
    
    colorValue *values = valueCollection->values;
    
    CGFloat distance;
    
    do {
        // Find the nearest cluster for all points
        for (NSUInteger i = 0; i < valueCollection->count; i++) {
            colorValue *value = &values[i];
            CGFloat smallestDistance = CGFLOAT_MAX;
            for (NSUInteger j = 0; j < clusterCount; j++) {
                colorCluster *currentCluster = &clusters[j];
                CGFloat distance = euclideanDistance(value, &currentCluster->center);
                if (distance < smallestDistance) {
                    smallestDistance = distance;
                    value->cluster = currentCluster;
                }
            }
        }
        
        distance = 0;
        
        // Recalculate the center
        for (NSUInteger i = 0; i < clusterCount; i++) {
            colorCluster *currentCluster = &clusters[i];
            
            // copy over the old center, it will be gone later
            colorValue oldCenter = currentCluster->center;
            recalculateCenter(currentCluster, valueCollection);
            distance = MAX(distance, euclideanDistance(&oldCenter, &currentCluster->center));
        }
    } while (distance > smallestDistanceLimit);
    
    return clusters;
}

// Returns an NSArray of UIColors
+ (NSArray *)dominantColorsOfImage:(UIImage *)image sampleCount:(NSUInteger)count
{
    colorValueCollection *currentColorValueCollection = colorArrayFromImage(image);
    colorCluster *clusters = colorClusters(currentColorValueCollection, count, 1);
    
    // We don't need the colorValues anymore
    free(currentColorValueCollection->values);
    free(currentColorValueCollection);
    
    // We still have the clusters and the center points.
    // Create UIColor objects for those
    NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        colorValue currentColor = clusters[i].center;
        UIColor *colorObj = [UIColor colorWithRed:currentColor.red green:currentColor.green blue:currentColor.blue alpha:1];
        [colorArray addObject:colorObj];
    }
    
    // Now free the clusters too
    free(clusters);
    
    return colorArray;
}

@end
