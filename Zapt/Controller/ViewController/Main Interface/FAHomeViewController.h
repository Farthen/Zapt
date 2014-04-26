//
//  FAHomeViewController.h
//  Zapt
//
//  Created by Finn Wilke on 08.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"
#import "FAArrayTableViewDelegate.h"
#import "FAViewControllerPreferredContentSizeChanged.h"
#import "FATableViewController.h"

@interface FAHomeViewController : FATableViewController <FAArrayTableViewDelegate, FAViewControllerPreferredContentSizeChanged>

@end
