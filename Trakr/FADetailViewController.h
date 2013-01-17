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

@interface FADetailViewController : UIViewController

- (void)showDetailForMovie:(FATraktMovie *)movie;
- (void)showDetailForShow:(FATraktShow *)show;
- (void)showDetailForEpisode:(FATraktEpisode *)episode;

@property (retain) IBOutlet UIBarButtonItem *actionButton;

@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UIView *contentView;

@property (retain) IBOutlet UIImageView *backgroundImageView;
@property (retain) IBOutlet UIImageView *coverImageView;

@property (retain) IBOutlet UILabel *titleLabel;
@property (retain) IBOutlet UILabel *detailLabel1;
@property (retain) IBOutlet UILabel *detailLabel2;
@property (retain) IBOutlet UILabel *detailLabel3;
@property (retain) IBOutlet UILabel *detailLabel4;
@property (retain) IBOutlet UILabel *overviewLabel;

@end
