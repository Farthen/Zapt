//
//  FADetailViewController.h
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FATraktMovie;

@interface FADetailViewController : UIViewController

- (void)showDetailForMovie:(FATraktMovie *)movie;

@property (retain) IBOutlet UIImageView *coverImageView;

@property (retain) IBOutlet UILabel *titleLabel;
@property (retain) IBOutlet UILabel *producerLabel;
@property (retain) IBOutlet UILabel *releaseDateLabel;
@property (retain) IBOutlet UILabel *taglineLabel;

@end
