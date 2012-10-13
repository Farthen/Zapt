//
//  FASearchResultTableViewCell.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchResultTableViewCell.h"

@implementation FASearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutSubviews];
        self.textLabel.font = [UIFont boldSystemFontOfSize:18];
        self.textLabel.textColor = [UIColor blackColor];
        
        UIFont *auxiliaryFont = [UIFont systemFontOfSize:14];
        UIColor *auxiliaryTextColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        self.detailTextLabel.font = auxiliaryFont;
        self.detailTextLabel.textColor = auxiliaryTextColor;
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _leftAuxiliaryTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 30, 280, 15)];
        self.leftAuxiliaryTextLabel.font = auxiliaryFont;
        self.leftAuxiliaryTextLabel.textColor = auxiliaryTextColor;
        self.leftAuxiliaryTextLabel.highlightedTextColor = [UIColor whiteColor];
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.leftAuxiliaryTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:self.leftAuxiliaryTextLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(9, 5, 280, 21);
    self.detailTextLabel.frame = CGRectMake(9, 48, 280, 15);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
