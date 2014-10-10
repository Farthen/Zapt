//
//  FARecommendationsListViewController.h
//  Zapt
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"
#import "FATrakt.h"
#import "FAArrayTableViewDelegate.h"
#import "FAViewControllerPreferredContentSizeChanged.h"

@interface FARecommendationsListViewController : FATableViewController <UISearchBarDelegate, FAArrayTableViewDelegate, FAViewControllerPreferredContentSizeChanged>

- (void)loadRecommendations;

@property IBOutlet UISearchBar *searchBar;

@end
