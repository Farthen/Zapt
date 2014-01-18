//
//  FASettingsViewController.h
//  Zapt
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FASettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (retain) IBOutlet UITableView *tableView;

- (IBAction)actionDoneButton:(id)sender;

@end
