//
//  NSString+StringByAppendingFilenameSuffix.h
//  Trakr
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringByAppendingFilenameSuffix)

- (NSString *)stringByAppendingFilenameSuffix:(NSString *)suffix;

@end
