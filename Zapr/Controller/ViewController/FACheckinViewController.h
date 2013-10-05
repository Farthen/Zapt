//
//  FACheckinViewController.h
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FANextUpViewController.h"
#import "FAViewControllerPreferredContentSizeChanged.h"

#import "FATraktCheckin.h"
#import "FAHorizontalProgressView.h"

@interface FACheckinViewController : UIViewController <FAViewControllerPreferredContentSizeChanged>

@property IBOutlet FAHorizontalProgressView *progressView;
@property IBOutlet UILabel *messageLabel;
@property IBOutlet UILabel *contentNameLabel;

@property FANextUpViewController *nextUpViewController;

@property IBOutlet NSLayoutConstraint *nextUpHeightConstraint;

- (void)loadContent:(FATraktContent *)content;
- (void)loadCheckin:(FATraktCheckin *)checkin;

@end
