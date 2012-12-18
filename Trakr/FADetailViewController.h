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

@interface FADetailViewController : UIViewController

- (void)showDetailForMovie:(FATraktMovie *)movie;
- (void)showDetailForShow:(FATraktShow *)show;

@property (retain) IBOutlet UIScrollView *scrollView;
@property (retain) IBOutlet UIView *contentView;

@property (retain) IBOutlet UIImageView *coverImageView;

@property (retain) IBOutlet UILabel *titleLabel;
@property (retain) IBOutlet UILabel *directorLabel;
@property (retain) IBOutlet UILabel *releaseDateLabel;
@property (retain) IBOutlet UILabel *taglineLabel;

@end
