//
//  FAFanartImageView.m
//  Zapr
//
//  Created by Finn Wilke on 13.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAFanartImageView.h"
#import "UIView+FrameAdditions.h"

@implementation FAFanartImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return [self intrinsicContentSizeForWidth:self.frame.size.width];
}

- (CGSize)intrinsicContentSizeForWidth:(CGFloat)width
{
    CGFloat height;
    if (self.image) {
        CGFloat imageWidth = self.image.size.width;
        CGFloat scaleFactor = width / imageWidth;
        height = self.image.size.height * scaleFactor;
    } else {
        height = 120;
    }
    return CGSizeMake(width, height);
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    [self invalidateIntrinsicContentSize];
}
/*
- (void)setFrame:(CGRect)frame
{
    frame.size = [self intrinsicContentSize];
    [super setFrame:frame];
}*/

- (void)setBounds:(CGRect)bounds
{
    bounds.size = [self intrinsicContentSizeForWidth:bounds.size.width];
    [super setBounds:bounds];
    [self invalidateIntrinsicContentSize];
    [self.superview setNeedsUpdateConstraints];
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
