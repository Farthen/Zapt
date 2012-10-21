//
//  FAStatusBarSpinnerController.h
//  Trakr
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAUIElementWithActivity.h"

@interface FAStatusBarSpinnerController : NSObject <FAUIElementWithActivity>

+ (FAStatusBarSpinnerController *)sharedInstance;

@end
