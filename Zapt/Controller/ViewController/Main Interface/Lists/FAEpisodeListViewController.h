//
//  FAEpisodeListViewController.h
//  Zapt
//
//  Created by Finn Wilke on 17.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"

@class FATraktShow;
@class FATraktSeason;

@interface FAEpisodeListViewController : FATableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

- (void)showEpisodeListForShow:(FATraktShow *)show;
- (void)showEpisodeListForSeason:(FATraktSeason *)season;
- (void)loadEpisodeListForShow:(FATraktShow *)show;

@end
