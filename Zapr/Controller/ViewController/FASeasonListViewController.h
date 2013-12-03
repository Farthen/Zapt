//
//  FASeasonListViewController.h
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATableViewController.h"
@class FATraktShow;

@interface FASeasonListViewController : FATableViewController

- (void)loadShow:(FATraktShow *)show;

@end
