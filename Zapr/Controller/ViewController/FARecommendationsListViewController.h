//
//  FARecommendationsListViewController.h
//  Zapr
//
//  Created by Finn Wilke on 15/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"
#import "FATraktContent.h"
#import "FAArrayTableViewDelegate.h"

@interface FARecommendationsListViewController : FATableViewController <UISearchBarDelegate, FAArrayTableViewDelegate>

- (void)loadRecommendations;

@property IBOutlet UISearchBar *searchBar;

@end
