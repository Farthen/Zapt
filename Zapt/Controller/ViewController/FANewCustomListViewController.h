//
//  FANewCustomListViewController.h
//  Zapt
//
//  Created by Finn Wilke on 09/03/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktList;

@interface FANewCustomListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextFieldDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;

- (void)editModeWithList:(FATraktList *)list;

@end
