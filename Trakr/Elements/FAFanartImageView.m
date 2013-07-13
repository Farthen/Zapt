//
//  FAFanartImageView.m
//  Trakr
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

    CGFloat width = self.superview.frameWidth;
    CGFloat height;
    if (self.image) {
        CGFloat imageWidth = self.image.size.width;
        CGFloat scaleFactor = width / imageWidth;
        height = self.image.size.height * scaleFactor;
    } else {
        height = 120;
    }
    NSLog(@"Intrinsic content size of image view: %fx%f", width, height);
    return CGSizeMake(width, height);
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
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
