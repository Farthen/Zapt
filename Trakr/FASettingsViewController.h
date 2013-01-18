//
//  FASettingsViewController.h
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FASettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain) IBOutlet UITableView *tableView;

@end
