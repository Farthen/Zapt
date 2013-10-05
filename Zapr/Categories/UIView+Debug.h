//
//  UIView+Debug.h
//  Zapr
//
//  Created by Finn Wilke on 04.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#ifdef DEBUG

#import <UIKit/UIKit.h>

@interface UIView (Debug)

- (void)recursiveExerciseAmbiguityInLayout;

@end

#endif