//
//  FAListDetailViewController.h
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAViewControllerPreferredContentSizeChanged.h"
#import <FATrakt/FATrakt.h>
@class FARefreshControlWithActivity;

@interface FAListDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FAViewControllerPreferredContentSizeChanged>

typedef enum {
    FAWatchlistTypeMovies = 0,
    FAWatchlistTypeShows = 1,
    FAWatchlistTypeEpisodes = 2
} FAWatchlistTypes;

- (void)loadWatchlistOfType:(FATraktContentType)type;
- (void)loadLibraryOfType:(FATraktContentType)type;
- (void)loadCustomList:(FATraktList *)list;

@property (retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) FARefreshControlWithActivity *refreshControlWithActivity;
//@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UISearchBar *searchBar;

@end
