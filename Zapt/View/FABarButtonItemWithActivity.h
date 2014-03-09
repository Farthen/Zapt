//
//  FABarButtonItemWithActivity.h
//  Zapt
//
//  Created by Finn Wilke on 09/03/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUIElementWithActivity.h"

@interface FABarButtonItemWithActivity : UIBarButtonItem <FAUIElementWithActivity>

@property (atomic, retain, readwrite) UIActivityIndicatorView *activityIndicatorView;

@end
