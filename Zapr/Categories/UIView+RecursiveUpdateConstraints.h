//
//  UIView+RecursiveUpdateConstraints.h
//  Zapr
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RecursiveUpdate)

- (void)recursiveSetNeedsUpdateConstraints;
- (void)recursiveSetNeedsLayout;
- (void)recursiveLayoutIfNeeded;

@end
