//
//  FAListDetailViewController.h
//  Trakr
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATrakt.h"

@interface FAListDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

typedef enum {
    FAWatchlistTypeMovies = 0,
    FAWatchlistTypeShows = 1,
    FAWatchlistTypeEpisodes = 2
} FAWatchlistTypes;

- (void)loadWatchlistOfType:(FAContentType)type;

@property (retain) IBOutlet UISegmentedControl *segmentedControl;
@property (retain) IBOutlet UITableView *tableView;

@end
