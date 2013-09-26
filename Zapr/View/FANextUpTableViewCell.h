//
//  FANextUpTableViewCell.h
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FANextUpTableViewCell : UITableViewCell

@property IBOutlet UILabel *nextUpLabel;
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UILabel *seasonLabel;

+ (CGFloat)cellHeight;

@end
