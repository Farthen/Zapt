//
//  FANextUpViewController.h
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAViewControllerPreferredContentSizeChanged.h"
@class FAHorizontalProgressView;
@class FATraktEpisode;
@class FATraktShowProgress;

@interface FANextUpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FAViewControllerPreferredContentSizeChanged>

@property IBOutlet FAHorizontalProgressView *progressView;
@property IBOutlet UITableView *tableView;
@property NSString *nextUpText;

@property IBOutlet NSLayoutConstraint *progressViewHeightConstraint;
@property IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property BOOL dismissesModalToDisplay;

- (void)displayProgress:(FATraktShowProgress *)progress;
- (void)displayNextUp:(FATraktEpisode *)content;
- (void)hideNextUp;

@end
