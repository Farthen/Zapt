//
//  CGFunctions.c
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#include <stdio.h>
#include "CGFunctions.h"
#include <CoreGraphics/CoreGraphics.h>

CGPoint CGPointAdd(CGPoint a, CGPoint b)
{
    CGPoint newPoint;
    newPoint.x = a.x + b.x;
    newPoint.y = a.y + b.y;
    return newPoint;
}

CGPoint CGPointSubtract(CGPoint a, CGPoint b)
{
    CGPoint newPoint;
    newPoint.x = a.x - b.x;
    newPoint.y = a.y - b.y;
    return newPoint;
}

CGSize CGSizeAdd(CGSize a, CGSize b)
{
    CGSize newSize;
    newSize.width = a.width + b.width;
    newSize.height = a.height + b.height;
    return newSize;
}

CGSize CGSizeSubtract(CGSize a, CGSize b)
{
    CGSize newSize;
    newSize.width = a.width - b.width;
    newSize.height = a.height - b.height;
    return newSize;
}

CGPoint CGRectCenter(CGRect rect)
{
    CGPoint center;
    center.x = rect.origin.x + (rect.size.width / 2);
    center.y = rect.origin.y + (rect.size.height / 2);
    return center;
}

CGRect CGRectCenteredToPoint(CGSize size, CGPoint center)
{
    CGRect rect;
    rect.size = size;
    rect.origin.x = center.x - (size.width / 2);
    rect.origin.y = center.y - (size.height / 2);
    return rect;
}
