//
//  FAImageTableViewCell.m
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAImageTableViewCell.h"
#import <FATrakt/FATrakt.h>

@implementation FAImageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (self) {
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

// http://stackoverflow.com/a/19106457/1084385
- (void)layoutSubviews
{
    [super layoutSubviews];
    // Makes imageView get placed in the corner
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    self.textLabel.frameX = 90;
    self.textLabel.frameWidth += self.detailTextLabel.frameX;
    
    self.detailTextLabel.frameX = 90;
    self.detailTextLabel.frameWidth += self.detailTextLabel.frameX;
    
    self.separatorInset = UIEdgeInsetsZero;
}

- (void)displaySeason:(FATraktSeason *)content
{
}

+ (CGFloat)cellHeight
{
    return 90;
}

@end
