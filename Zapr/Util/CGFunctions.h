//
//  CGFunctions.h
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#ifndef Zapr_CGFunctions_h
#define Zapr_CGFunctions_h

#include <CoreGraphics/CoreGraphics.h>

CGPoint CGPointAdd(CGPoint a, CGPoint b);
CGPoint CGPointSubtract(CGPoint a, CGPoint b);
CGPoint CGPointMultiply(CGPoint a, CGFloat factor);
CGPoint CGPointDivide(CGPoint a, CGFloat divisor);

CGSize CGSizeAdd(CGSize a, CGSize b);
CGSize CGSizeSubtract(CGSize a, CGSize b);
CGSize CGSizeMultiply(CGSize a, CGFloat factor);
CGSize CGSizeDivide(CGSize a, CGFloat divisor);

CGPoint CGRectCenter(CGRect rect);
CGRect CGRectCenteredToPoint(CGSize size, CGPoint center);

#endif
