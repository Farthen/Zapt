//
//  FAShowListViewController.h
//  Zapt
//
//  Created by Finn Wilke on 26.02.14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"
#import "FAWeightedTableViewDataSource.h"
#import "FAArrayTableViewDelegate.h"
#import "FAViewControllerPreferredContentSizeChanged.h"

@interface FAShowListViewController : FATableViewController <UISearchBarDelegate, FAArrayTableViewDelegate, FAViewControllerPreferredContentSizeChanged>

- (void)loadShows;

@end
