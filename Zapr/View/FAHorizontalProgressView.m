//
//  FAProgressView.m
//  Zapr
//
//  Created by Finn Wilke on 19.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAHorizontalProgressView.h"
#import "FATraktContent.h"
#import "FAContentTableViewCell.h"

@interface FAHorizontalProgressView ()
@property (readonly) CGFloat progressBarHeight;
@property BOOL constraintsSetUp;
@end

@implementation FAHorizontalProgressView
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setUp];
}

- (void)setUp
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGRect textLabelFrame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 8, 0, 8));
    self.textLabel = [[UILabel alloc] initWithFrame:textLabelFrame];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.textColor = [UIColor whiteColor];
    
    self.fontTextStyle = UIFontTextStyleSubheadline;
    
    [self addSubview:self.textLabel];
    
    [self setNeedsLayout];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.constraintsSetUp) {
        self.constraintsSetUp = YES;
        
        NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:2],
                                 [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2],
                                 [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:8],
                                 [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
        
        for (NSLayoutConstraint *constraint in constraints) {
            constraint.priority = UILayoutPriorityRequired - 1;
        }
        
        [self addConstraints:constraints];
        
        [self.textLabel invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    if (self.progress) {
        return [super intrinsicContentSize];
    } else {
        return CGSizeZero;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.font = [UIFont preferredFontForTextStyle:self.fontTextStyle];
    
    [self.textLabel invalidateIntrinsicContentSize];
    [self invalidateIntrinsicContentSize];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect coloredRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.progressBarHeight);
    coloredRect.size.width *= _progress;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef tintColor = self.tintColor.CGColor;
    
    CGContextSetFillColorWithColor(context, tintColor);
    CGContextFillRect(context, coloredRect);
}

- (CGFloat)progressBarHeight
{
    return self.bounds.size.height;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (CGFloat)progress
{
    return _progress;
}


@end
