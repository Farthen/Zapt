//
//  UIView+ImageScreenshot.m
//  Zapt
//
//  Created by Finn Wilke on 27.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+ImageScreenshot.h"

@implementation UIView (ImageScreenshot)

- (UIImage *)imageScreenshot
{
    CGSize size = self.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return screenShot;
}

@end
