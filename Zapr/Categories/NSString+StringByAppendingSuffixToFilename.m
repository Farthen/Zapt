//
//  NSString+StringByAppendingFilenameSuffix.m
//  Zapr
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "NSString+StringByAppendingSuffixToFilename.h"

@implementation NSString (StringByAppendingFilenameSuffix)

// stolen from http://stackoverflow.com/questions/3953794/add-suffix-to-file-name-before-extension
- (NSString *)stringByAppendingFilenameSuffix:(NSString *)suffix
{
    NSString * containingFolder = [self stringByDeletingLastPathComponent];
    NSString * fullFileName = [self lastPathComponent];
    NSString * fileExtension = [fullFileName pathExtension];
    NSString * fileName = [fullFileName stringByDeletingPathExtension];
    NSString * newFileName = [fileName stringByAppendingString:suffix];
    NSString * newFullFileName = [newFileName stringByAppendingPathExtension:fileExtension];
    return [containingFolder stringByAppendingPathComponent:newFullFileName];
}

@end
