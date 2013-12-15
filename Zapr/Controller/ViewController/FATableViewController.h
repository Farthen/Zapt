//
//  FATableViewController.h
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FARefreshControlWithActivity.h"

@interface FATableViewController : UITableViewController

- (void)setUp;

- (void)setUpRefreshControlWithActivityWithRefreshDataBlock:(void (^)(FARefreshControlWithActivity *refreshControlWithActivity))refreshDataBlock;

typedef void (^FAViewControllerCompletionBlock)(void);
- (void)dispatchAfterViewDidLoad:(void (^)(void))completionBlock;

@property (nonatomic) FARefreshControlWithActivity *refreshControlWithActivity;

@end
