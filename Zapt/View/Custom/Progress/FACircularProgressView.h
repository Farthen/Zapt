//
//  FACheckinProgressView.h
//  Zapt
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAProgressView.h"

@interface FACircularProgressView : UIView <FAProgressView>

@property UIEdgeInsets contentInset;
@property CGFloat circleThickness;
@property UILabel *textLabel;

@end
