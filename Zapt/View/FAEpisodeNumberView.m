//
//  FAEpisodeNumberView.m
//  Zapt
//
//  Created by Finn Wilke on 08/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAEpisodeNumberView.h"

@interface FAEpisodeNumberView ()
@property (nonatomic) UILabel *numberLabel;
@end

@implementation FAEpisodeNumberView {
    BOOL _seen;
    NSInteger _episodeNumber;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)seen
{
    return _seen;
}

- (void)setSeen:(BOOL)seen
{
    _seen = seen;
    [self setNeedsDisplay];
}

- (NSInteger)episodeNumber
{
    return _episodeNumber;
}

- (void)setEpisodeNumber:(NSInteger)episodeNumber
{
    _episodeNumber = episodeNumber;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentScaleFactor = 2;
    
    if (!self.numberLabel) {
        self.numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        self.numberLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.numberLabel];
    }
    
    self.numberLabel.frame = self.bounds;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    rect = self.bounds;
    
    if (!self.numberLabel) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%li", self.episodeNumber];
    
    [[UIColor whiteColor] set];
    UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:rect];
    [backgroundRect fill];
    
    UIColor *highlightColor;
    
    if (self.seen) {
        highlightColor = [UIColor lightGrayColor];
    } else {
        highlightColor = self.tintColor;
    }
    
    [highlightColor set];
    
    UIBezierPath *highlightRect = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
    [highlightRect fill];
}


@end
