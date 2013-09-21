//
//  FADominantColorsAnalyzer.h
//  Zapr
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FADominantColorsAnalyzer : NSObject

+ (NSArray *)dominantColorsOfImage:(UIImage *)image sampleCount:(NSUInteger)count;

@end
