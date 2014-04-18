//
//  FASeasonDetailViewController.h
//  Zapt
//
//  Created by Finn Wilke on 13/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAViewController.h"
#import "FAEpisodeListViewController.h"

@interface FASeasonDetailViewController : FAViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate>

@property IBOutlet FAEpisodeListViewController *episodeListViewController;
@property IBOutlet UISearchBar *searchBar;

- (void)showEpisodeListForSeason:(FATraktSeason *)season;

@end
