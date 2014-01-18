//
//  FANextUpTableViewCell.h
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATableViewCellHeight.h"

@interface FANextUpTableViewCell : UITableViewCell <FATableViewCellHeight>

@property IBOutlet UILabel *nextUpLabel;
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UILabel *seasonLabel;

+ (CGFloat)cellHeight;
+ (CGFloat)cellHeightForTitle:(NSString *)title cell:(FANextUpTableViewCell *)cell;

@end
