//
//  FACheckinViewController.h
//  Zapt
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FANextUpViewController.h"
#import "FAViewControllerPreferredContentSizeChanged.h"

#import "FATraktCheckin.h"
#import "FAHorizontalProgressView.h"
#import "FAReloadControl.h"
#import "FASimpleControl.h"

@interface FACheckinViewController : UIViewController <FAViewControllerPreferredContentSizeChanged, UIAlertViewDelegate, UIActionSheetDelegate>

@property IBOutlet FAHorizontalProgressView *progressView;
@property IBOutlet FAReloadControl *reloadControl;

@property IBOutlet UILabel *messageLabel;
@property IBOutlet UILabel *contentNameLabel;
@property IBOutlet UILabel *showNameLabel;

@property IBOutlet FASimpleControl *statusControl;

@property FANextUpViewController *nextUpViewController;

@property IBOutlet NSLayoutConstraint *nextUpHeightConstraint;

- (void)loadContent:(FATraktContent *)content;
- (void)loadCheckin:(FATraktCheckin *)checkin;
- (void)performCheckinForContent:(FATraktContent *)content;

- (IBAction)actionStatusControl:(id)sender;

@end
