//
//  FAFirstViewController.h
//  Zapt
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAViewControllerPreferredContentSizeChanged.h"
@class FASearchData;
@class FATableViewLoadingView;
@class FANavigationController;

@interface FASearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, FAViewControllerPreferredContentSizeChanged>

@property (retain, atomic) FASearchData *searchData;
@property (retain) IBOutlet UISearchBar *searchBar;
//@property FANavigationController *navigationController;

- (IBAction)actionDoneButton:(id)sender;

@end
