//
//  CGFunctions.c
//  Trakr
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
