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
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
}

- (CGFloat)insetX
{
    return 5;
}

- (CGFloat)insetY
{
    return 0;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.origin.x += [self insetX];
    bounds.size.width -= 2 * [self insetX];
    bounds.origin.y = [self insetY];
    bounds.size.height -= 2 * [self insetY];
    return bounds;
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = super.intrinsicContentSize;
    intrinsicContentSize.width += [self insetX] * 2;
    intrinsicContentSize.height += [self insetY] * 2;
    return intrinsicContentSize;
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect: [self textRectForBounds:rect]];
    [self invalidateIntrinsicContentSize];
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
