//
//  FANextUpViewController.h
//  Trakr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FAProgressView;
@class FATraktContent;
@class FATraktShowProgress;

@interface FANextUpViewController : UIViewController

@property IBOutlet FAProgressView *progressView;
@property IBOutlet UILabel *progressLabel;
@property IBOutlet UILabel *episodeNameLabel;
@property IBOutlet UILabel *seasonLabel;

- (void)displayProgress:(FATraktShowProgress *)progress;
- (void)displayNextUp:(FATraktContent *)content;

- (CGFloat)intrinsicHeight;

@end
