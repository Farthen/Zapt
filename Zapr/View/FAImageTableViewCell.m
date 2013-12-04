//
//  FAImageTableViewCell.m
//  Zapr
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAImageTableViewCell.h"
#import "FATrakt.h"

@implementation FAImageTableViewCell

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

// http://stackoverflow.com/a/19106457/1084385
- (void)layoutSubviews
{
    [super layoutSubviews];
    // Makes imageView get placed in the corner
    self.imageView.frame = CGRectMake( 0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    // Get textlabel frame
    //self.textLabel.backgroundColor = [UIColor blackColor];
    CGRect textlabelFrame = self.textLabel.frame;
    
    // Figure out new width
    textlabelFrame.size.width = textlabelFrame.size.width + textlabelFrame.origin.x - 90;
    // Change origin to what we want
    textlabelFrame.origin.x = 90;
    
    // Assign the the new frame to textLabel
    self.textLabel.frame = textlabelFrame;
    
    self.separatorInset = UIEdgeInsetsZero;
}

- (void)displaySeason:(FATraktSeason *)content
{
    
}

@end
