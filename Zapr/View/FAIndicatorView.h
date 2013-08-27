//
//  FAIndicatorView.h
//  Zapr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAIndicatorView : UIView

typedef enum {
    FAIndicatorViewArrowDirectionLeft = 0,
    FAIndicatorViewArrowDirectionUp = 1,
    FAIndicatorViewArrowDirectionRight = 2,
    FAIndicatorViewArrowDirectionDown = 3,
} FAIndicatorViewArrowDirection;


@property (nonatomic, assign) FAIndicatorViewArrowDirection arrowDirection;
- (void)flip:(BOOL)doFlip;

@end
