//
//  FASeasonListViewController.h
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktShow;

@interface FASeasonListViewController : UITableViewController

- (void)loadShow:(FATraktShow *)show;

@end
