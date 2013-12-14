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
    [super layoutSubviews];
    
    self.nextUpLabel.font = self.class.nameFont;
    self.nameLabel.font = self.class.nameFont;
    self.seasonLabel.font = self.class.seasonFont;
}

- (void)prepareForReuse
{
    self.accessoryType = UITableViewCellAccessoryNone;
    [self.contentView setNeedsUpdateConstraints];
}

+ (UIFont *)nameFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (UIFont *)seasonFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

+ (CGFloat)cellHeightForTitle:(NSString *)title cell:(FANextUpTableViewCell *)cell
{
    CGFloat nameConstraint = cell.nameLabel.frame.size.width;
    CGSize nameSizeConstraint = CGSizeMake(nameConstraint, CGFLOAT_MAX);
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    context.minimumScaleFactor = 1.0;
    
    CGRect nameRect = [title boundingRectWithSize:nameSizeConstraint
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName: self.nameFont }
                                          context:context];
    
    CGSize seasonSize = [@"S01E01" sizeWithAttributes : @{ NSFontAttributeName : self.seasonFont }];
    CGSize nextUpSize = [@"Next Up:" sizeWithAttributes : @{ NSFontAttributeName : self.seasonFont }];
    
    CGFloat rightHeight = 0;
    rightHeight += 5;
    rightHeight += ceilf(nameRect.size.height);
    rightHeight += 8;
    
    CGFloat leftHeight = 0;
    leftHeight += 5;
    leftHeight += ceilf(nextUpSize.height);
    leftHeight += 2;
    leftHeight += ceilf(seasonSize.height);
    leftHeight += 8;
    
    CGFloat height = MAX(leftHeight, rightHeight);
    
    return height;
}

+ (CGFloat)cellHeight
{
    // More yolo swag fun fun fun
    CGSize nameSize = [@"Title" sizeWithAttributes : @{ NSFontAttributeName : self.nameFont }];
    CGSize seasonSize = [@"S01E01" sizeWithAttributes : @{ NSFontAttributeName : self.seasonFont }];
    CGSize nextUpSize = [@"Next Up:" sizeWithAttributes : @{ NSFontAttributeName : self.seasonFont }];
    
    // Now calculate this crap
    CGFloat rightHeight = 0;
    rightHeight += 5;
    rightHeight += ceilf(nameSize.height);
    rightHeight += 8;
    
    CGFloat leftHeight = 0;
    leftHeight += 5;
    leftHeight += ceilf(nextUpSize.height);
    leftHeight += 2;
    leftHeight += ceilf(seasonSize.height);
    leftHeight += 8;
    
    CGFloat height = MAX(leftHeight, rightHeight);
    
    return height;
}

@end
