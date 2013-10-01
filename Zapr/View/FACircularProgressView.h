//
//  FACheckinProgressView.h
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FACircularProgressView : UIView

@property CGFloat progress;
@property UIEdgeInsets contentInset;
@property CGFloat circleThickness;
@property (readonly) UILabel *label;

@end
