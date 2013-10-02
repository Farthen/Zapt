//
//  FACheckinViewController.h
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATraktCheckin.h"
#import "FAHorizontalProgressView.h"

@interface FACheckinViewController : UIViewController

@property IBOutlet FAHorizontalProgressView *progressView;

- (void)loadContent:(FATraktContent *)content;
- (void)loadCheckin:(FATraktCheckin *)checkin;

@end
