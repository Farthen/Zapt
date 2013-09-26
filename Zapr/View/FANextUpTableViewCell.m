//
//  FANextUpTableViewCell.m
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FANextUpTableViewCell.h"

@implementation FANextUpTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    self.nextUpLabel.font = self.class.nameFont;
    self.nameLabel.font = self.class.nameFont;
    self.seasonLabel.font = self.class.seasonFont;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)prepareForReuse
{
    self.accessoryType = UITableViewCellAccessoryNone;
}

+ (UIFont *)nameFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIFont *)seasonFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (CGFloat)cellHeight
{
    // More yolo swag fun fun fun
    CGSize nameSize = [@"Title" sizeWithAttributes:@{NSFontAttributeName: self.nameFont}];
    CGSize seasonSize = [@"Detail" sizeWithAttributes:@{NSFontAttributeName: self.seasonFont}];
    
    // Now calculate this crap
    CGFloat height = 0;
    
    height += 5;
    height += nameSize.height;
    height += 5;
    height += seasonSize.height;
    height += 8;
    return ceil(height);
}

@end
