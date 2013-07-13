//
//  FAFirstViewController.h
//  Trakr
//
//  Created by Finn Wilke on 31.08.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FASearchData;
@class FATableViewLoadingView;
@class FASearchBarWithActivity;

@interface FASearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (retain) FASearchData *searchData;
@property (retain) IBOutlet FASearchBarWithActivity *searchBar;

- (IBAction)actionDoneButton:(id)sender;

@end
