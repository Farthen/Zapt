//
//  FAPullScrollViewAccessoryView.m
//  Zapt
//
//  Created by Finn Wilke on 13/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAPullScrollViewAccessoryView.h"
#import "FAArrowView.h"
#import <CoreText/CoreText.h>

@interface FAPullScrollViewAccessoryView ()
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) FAArrowView *arrowView;

@property (nonatomic) UIScrollView *parentScrollView;
@property (nonatomic) BOOL addedConstraints;

@property (nonatomic) BOOL isBottom;
@end

@implementation FAPullScrollViewAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.arrowView = [[FAArrowView alloc] init];
        self.arrowView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.textLabel];
        [self addSubview:self.arrowView];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Light" size:12];
        
        /*UIFont *font = [UIFont fontWithName:@"Didot" size:17];
        
        UIFontDescriptor *descriptor = [font fontDescriptor];
        NSArray *array = @[@{UIFontFeatureTypeIdentifierKey : @(kLetterCaseType),
                             UIFontFeatureSelectorIdentifierKey : @(kSmallCapsSelector)}];
        descriptor = [descriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorFeatureSettingsAttribute : array}];
        font = [UIFont fontWithDescriptor:descriptor size:0];*/
        
        self.textLabel.font = font;
        self.textLabel.textColor = [UIColor darkGrayColor];
        
        [self setNeedsLayout];
        
        self.hidden = YES;
        self.opaque = NO;
    }
    
    return self;
}

- (void)addSubviewConstraints
{
    if (!self.addedConstraints) {
        self.addedConstraints = YES;
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
         
        
        if (!self.isBottom) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.arrowView attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
        } else {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.arrowView attribute:NSLayoutAttributeBottom multiplier:1 constant:8]];
        }
        
        [self setNeedsUpdateConstraints];
        [self setNeedsLayout];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil && self.parentScrollView) {
        [self.parentScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.parentScrollView removeObserver:self forKeyPath:@"contentSize"];
        [self.parentScrollView removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)layoutSubviews
{
    [self setPosition];
    [super layoutSubviews];
}

- (void)setPosition
{
    CGRect frame = self.frame;
    
    
    if (self.isBottom) {
        frame.origin.y = MAX(self.parentScrollView.contentSize.height - self.parentScrollView.contentInset.bottom, self.parentScrollView.frame.size.height - self.parentScrollView.contentInset.bottom - self.parentScrollView.contentInset.top) + 8;
    } else {
        frame.origin.y = - self.frame.size.height - 8;
    }
    
    frame.origin.x = (self.parentScrollView.contentSize.width / 2) - (frame.size.width / 2);
    
    self.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] || [keyPath isEqualToString:@"contentSize"]) {
        [self setPosition];
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat offset = 0;
        
        CGFloat scrollHeight = self.parentScrollView.frame.size.height;
        CGFloat scrollContentHeight = self.parentScrollView.contentSize.height;
        CGFloat contentOffset = self.parentScrollView.contentOffset.y;
        CGFloat contentInset = self.parentScrollView.contentInset.top;
        
        if (self.isBottom) {
            offset = MIN(contentOffset - (scrollContentHeight - scrollHeight), contentOffset + contentInset);
        } else {
            offset = - (self.parentScrollView.contentOffset.y + contentInset);
        }
        
        if (offset > 0) {
            self.hidden = NO;
            self.alpha = MIN(1, offset / 40.0);
        } else {
            self.hidden = YES;
        }
        
        self.arrowView.progress = MAX(0, MIN(1, (offset - 40) / 50));
        
        if (offset >= 100) {
        } else {
        }
    }
}

- (void)addToScrollView:(UIScrollView *)scrollView bottom:(BOOL)bottom
{
    self.isBottom = bottom;
    self.parentScrollView = scrollView;
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addSubviewConstraints];
    [self setPosition];
    
    self.arrowView.upArrow = !bottom;
    
    [scrollView addSubview:self];
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
