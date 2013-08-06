//
//  FAContentBookmarkViewController.h
//  Trakr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktContent;

@interface FAContentBookmarkViewController : UITableViewController

@property IBOutlet UILabel *watchlistLabel;
@property IBOutlet UILabel *libraryLabel;
@property IBOutlet UILabel *customListsDetailLabel;
@property IBOutlet UILabel *ratingDetailLabel;

- (void)displayContent:(FATraktContent *)content;

@end
