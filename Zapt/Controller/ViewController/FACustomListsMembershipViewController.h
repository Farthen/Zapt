//
//  FACustomListsMembershipViewController.h
//  Zapt
//
//  Created by Finn Wilke on 28.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FACustomListsMembershipTableViewController;
@class FATraktContent;

@interface FACustomListsMembershipViewController : UINavigationController

- (void)loadContent:(FATraktContent *)content;

@end
