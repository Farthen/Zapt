//
//  FAProgressView.h
//  Zapt
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAProgressView.h"

@class FATraktContent;

@interface FAHorizontalProgressView : UIView <FAProgressView>

@property NSString *fontTextStyle;
@property UILabel *textLabel;

@end