//
//  FADetailViewController.h
//  Zapt
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAViewControllerPreferredContentSizeChanged.h"
#import "FASemiModalEnabledViewController.h"
#import "FAAppDelegate.h"
#import "FAContentBookmarkViewController.h"
#import "FAPullScrollViewAccessoryView.h"

@class FATitleLabel;
@class FATraktContent;
@class FANextUpViewController;

@interface FADetailViewController : FASemiModalEnabledViewController <UIViewControllerTransitioningDelegate, UIActionSheetDelegate, FAViewControllerPreferredContentSizeChanged, FAContentBookmarkViewControllerDelegate, FAPullScrollViewAccessoryViewDelegate>

- (void)loadContent:(FATraktContent *)content;

- (IBAction)actionItem:(id)sender;
- (IBAction)actionDetailLabel:(id)sender;

- (IBAction)pushedBookmarkButton:(id)sender;
- (IBAction)pushedShareButton:(id)sender;

// This will be set by the nextUpViewController when it is inserted as sub view controller
@property FANextUpViewController *nextUpViewController;
@property IBOutlet NSLayoutConstraint *nextUpHeightConstraint;

@property (retain) IBOutlet UIBarButtonItem *actionButton;
@property (retain) IBOutlet UIBarButtonItem *ratingsButton;

//@property (retain) IBOutlet FAScrollViewWithTopView *scrollView;
@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UIView *contentView;

@property (retain) IBOutlet UIImageView *coverImageView;

@property (retain) IBOutlet FATitleLabel *titleLabel;
@property IBOutlet UILabel *detailLabel;
@property IBOutlet NSLayoutConstraint *detailViewHeightConstraint;

@property (retain) IBOutlet UILabel *overviewLabel;

@property (retain) IBOutlet NSLayoutConstraint *imageViewToTopLayoutConstraint;
@property (retain) IBOutlet NSLayoutConstraint *imageViewToBottomViewLayoutConstraint;
@property (retain) IBOutlet NSLayoutConstraint *coverImageViewHeightConstraint;


@end
