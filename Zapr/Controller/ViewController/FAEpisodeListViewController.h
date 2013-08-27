//
//  FAEpisodeListViewController.h
//  Trakr
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FATraktShow;

@interface FAEpisodeListViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource>

- (void)showEpisodeListForShow:(FATraktShow *)show;

@end
