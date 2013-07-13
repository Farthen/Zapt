//
//  FADetailViewController.h
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktMovie;
@class FATraktShow;
@class FATraktEpisode;
@class FATitleLabel;
@class FATraktContent;
@class FAScrollViewWithTopView;

@interface FADetailViewController : UIViewController <UIActionSheetDelegate>

- (void)loadContent:(FATraktContent *)content;

- (IBAction)actionDoneButton:(id)sender;
- (IBAction)actionItem:(id)sender;

@property (retain) IBOutlet UIBarButtonItem *actionButton;

//@property (retain) IBOutlet FAScrollViewWithTopView *scrollView;
@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UIView *contentView;

@property (retain) IBOutlet UIImageView *coverImageView;
@property (retain) IBOutlet UIView *detailBackgroundView;
@property (retain) IBOutlet UIView *titleBackgroundView;
@property (retain) IBOutlet UIView *scrollViewBackgroundView;

@property (retain) IBOutlet FATitleLabel *titleLabel;
@property (retain) IBOutlet UILabel *detailLabel1;
@property (retain) IBOutlet UILabel *detailLabel2;
@property (retain) IBOutlet UILabel *detailLabel3;
@property (retain) IBOutlet UILabel *detailLabel4;
@property (retain) IBOutlet UILabel *overviewLabel;



@property (retain) IBOutlet NSLayoutConstraint *imageViewToTopLayoutConstraint;
@property (retain) IBOutlet NSLayoutConstraint *imageViewToBottomViewLayoutConstraint;

@end
