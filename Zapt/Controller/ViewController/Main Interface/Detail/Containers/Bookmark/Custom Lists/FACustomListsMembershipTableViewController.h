//
//  FACustomListsMembershipViewController.h
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktContent;

@interface FACustomListsMembershipTableViewController : UITableViewController

- (void)loadContent:(FATraktContent *)content;
- (IBAction)doneButtonPressed:(id)sender;

@end
