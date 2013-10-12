//
//  FALoggedInTableViewController.h
//  Zapr
//
//  Created by Finn Wilke on 29.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FALoggedInTableViewController : UITableViewController

@property NSString *needsLoginContentName;

- (void)showNeedsLoginTableViewAnimated:(BOOL)animated;
- (void)hideNeedsLoginTableViewAnimated:(BOOL)animated;
- (void)displayNeedsLoginTableViewIfNeeded;

@end
