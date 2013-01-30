//
//  FATitleLabel.m
//  Trakr
//
//  Created by Finn Wilke on 29.01.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATitleLabel.h"

@implementation FATitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    return;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x + 5, bounds.origin.y + 2, bounds.size.width - 10, bounds.size.height - 4);
    return inset;
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect: [self textRectForBounds:rect]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
