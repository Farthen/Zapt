//
//  NSString+Base64Encode.h
//  Zapr
//
//  Created by Finn Wilke on 17.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64Encode)

- (NSString *)base64EncodedString;
+ (NSString *)stringByBase64EncodingData:(NSData *)theData;

@end
