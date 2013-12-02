//
//  UIImage+SizeInBytes.m
//  Zapr
//
//  Created by Finn Wilke on 02/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIImage+SizeInBytes.h"

@implementation UIImage (SizeInBytes)

- (NSUInteger)sizeInBytes
{
    CGSize size = self.size;
    CGImageRef cgImage = self.CGImage;
    
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(cgImage);
    NSUInteger bytes = bytesPerRow * floor(size.height);
    
    return bytes;
}

@end
