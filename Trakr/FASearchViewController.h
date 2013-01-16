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

typedef enum {
    FASearchScopeMovies = 0,
    FASearchScopeShows = 1,
    FASearchScopeEpisodes = 2
} FASearchScope;

@interface FASearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (retain) FASearchData *searchData;

@property (retain) IBOutlet FASearchBarWithActivity *searchBar;

@end
