//
//  FACheckinViewController.h
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FACircularProgressView.h"

@interface FACheckinViewController : UIViewController

@property IBOutlet FACircularProgressView *progressView;

- (void)loadProgress:(CGFloat)progress;

@end
