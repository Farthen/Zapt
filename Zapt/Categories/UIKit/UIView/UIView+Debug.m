//
//  UIView+Debug.m
//  Zapt
//
//  Created by Finn Wilke on 04.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIView+Debug.h"

@implementation UIView (Debug)

- (void)recursiveExerciseAmbiguityInLayout
{
    for (id view in self.subviews) {
        if ([view respondsToSelector:@selector(recursiveExerciseAmbiguityInLayout)]) {
            [view recursiveExerciseAmbiguityInLayout];
        } else if ([view respondsToSelector:@selector(exerciseAmbiguityInLayout)]) {
            [view exerciseAmbiguityInLayout];
        }
    }
    
    [self exerciseAmbiguityInLayout];
}

@end
