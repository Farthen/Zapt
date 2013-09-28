//
//  FANextUpViewController.h
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAAppDelegate.h"
@class FAProgressView;
@class FATraktContent;
@class FATraktShowProgress;

@interface FANextUpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FAViewControllerPreferredContentSizeChanged>

@property IBOutlet FAProgressView *progressView;
@property IBOutlet UILabel *progressLabel;
@property IBOutlet UILabel *episodeNameLabel;
@property IBOutlet UILabel *seasonLabel;
@property IBOutlet UITableView *tableView;

@property IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

- (void)displayProgress:(FATraktShowProgress *)progress;
- (void)displayNextUp:(FATraktContent *)content;

@end
