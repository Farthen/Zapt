//
//  FAOverlayView.h
//  Zapr
//
//  Created by Finn Wilke on 24.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

// This is clear except where intersectingViews intersect with this view. It displays overlayImage instead
@interface FAOverlayView : UIView

@property UIImage *overlayImage;
@property NSArray *intersectingViews;

@end
