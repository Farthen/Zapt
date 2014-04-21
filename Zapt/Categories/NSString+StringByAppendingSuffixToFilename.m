//
//  NSString+StringByAppendingFilenameSuffix.m
//  Zapt
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "NSString+StringByAppendingSuffixToFilename.h"

@implementation NSString (StringByAppendingFilenameSuffix)

// stolen from http://stackoverflow.com/questions/3953794/add-suffix-to-file-name-before-extension
- (NSString *)stringByAppendingFilenameSuffix:(NSString *)suffix
{
    NSString *containingFolder = [self stringByDeletingLastPathComponent];
    NSString *fullFileName = [self lastPathComponent];
    NSString *fileExtension = [fullFileName pathExtension];
    NSString *fileName = [fullFileName stringByDeletingPathExtension];
    NSString *newFileName = [fileName stringByAppendingString:suffix];
    NSString *newFullFileName = [newFileName stringByAppendingPathExtension:fileExtension];
    
    return [containingFolder stringByAppendingPathComponent:newFullFileName];
}

- (NSString *)urlStringByAppendingFilenameSuffix:(NSString *)suffixString
{
    NSURL *url = [NSURL URLWithString:self];
    
    NSString *extension = [url pathExtension];
    NSURL *urlWithoutExtension = [url URLByDeletingPathExtension];
    NSString *urlStringWithSuffix = [[urlWithoutExtension absoluteString] stringByAppendingString:suffixString];
    
    NSURL *urlWithSuffix = [NSURL URLWithString:urlStringWithSuffix];
    return [[urlWithSuffix URLByAppendingPathExtension:extension] absoluteString];
}

@end
