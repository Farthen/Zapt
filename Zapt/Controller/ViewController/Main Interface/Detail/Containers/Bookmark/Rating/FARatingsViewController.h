//
//  FARatingsViewController.h
//  Zapt
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FARatingsView.h"

@interface FARatingsViewController : UIViewController <FARatingsViewDelegate>
- (instancetype)initWithContent:(FATraktContent *)content;

@end
