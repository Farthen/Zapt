//
//  FAOverlayView.m
//  Trakr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAOverlayView.h"

@implementation FAOverlayView {
    UIImage *_overlayImage;
    CGImageRef _overlayContextImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIImage *)overlayImage
{
    return _overlayImage;
}

- (void)setOverlayImage:(UIImage *)overlayImage
{
    if (_overlayContextImage) {
        CGImageRelease(_overlayContextImage);
    }
    
    _overlayImage = overlayImage;
    
    // Create a context and draw the image inside
    CGRect rect = self.bounds;
    CGRect newRect = CGRectIntegral(rect);
    
    CGImageRef imageRef = [_overlayImage CGImage];
    
    CGContextRef context = CGBitmapContextCreate (NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    if (context == nil) {
        return;
    }
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height + self.bounds.origin.y);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, newRect, imageRef);
    //[_overlayImage drawInRect:newRect];
    
    // This will be released later when not needed anymore
    _overlayContextImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    for (UIView *view in self.intersectingViews) {
        // Convert the possibly intersecting view's bounds to own coordinate system
        CGRect intersectingFrame = [self convertRect:[view.layer.presentationLayer bounds] fromView:view];
        CGRect rectIntersection = CGRectIntersection(rect, intersectingFrame);
        CGRect flippedRectIntersection;
        flippedRectIntersection.origin.x = rectIntersection.origin.x;
        flippedRectIntersection.origin.y = self.bounds.size.height - (rectIntersection.origin.y + rectIntersection.size.height);
        flippedRectIntersection.size.width = rectIntersection.size.width;
        flippedRectIntersection.size.height = rectIntersection.size.height;
        
        if (!CGRectIsNull(rectIntersection)) {
            // We have an intersection and will draw the overlayImageView in the rect
            
            CGImageRef intersectionImage = CGImageCreateWithImageInRect(_overlayContextImage, flippedRectIntersection);

            CGContextDrawImage(context, rectIntersection, intersectionImage);
            CGImageRelease(intersectionImage);
        }
    }
}

- (void)dealloc
{
    if (_overlayContextImage) {
        CGImageRelease(_overlayContextImage);
    }
}

@end
