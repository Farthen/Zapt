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
#import "FANotificationScrollViewDelegate.h"

@interface FAPullScrollViewAccessoryView ()
@property (nonatomic) UILabel *textLabel;
@property (nonatomic) FAArrowView *arrowView;

@property (nonatomic) UIScrollView *parentScrollView;
@property (nonatomic) BOOL addedConstraints;

@property (nonatomic) BOOL isBottom;

@property (nonatomic) BOOL didBeginPulling;
@property (nonatomic) BOOL pullSuccess;

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
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}
- (CGFloat)scrollOffset
{
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
    
    return offset;
}

- (CGFloat)offsetThreshold
{
    return 80;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGFloat offset = [self scrollOffset];
        
        if (offset > 0) {
            self.hidden = NO;
            self.alpha = MIN(1, offset / 40.0);
            
            if (!self.didBeginPulling) {
                self.didBeginPulling = YES;
                self.pullSuccess = NO;
                
                if ([self.delegate respondsToSelector:@selector(pullScrollViewAccessoryViewBeganPulling:)]) {
                    [self.delegate pullScrollViewAccessoryViewBeganPulling:self];
                }
            }
        } else {
            self.hidden = YES;
            
            if (self.didBeginPulling) {
                self.didBeginPulling = NO;
                
                if (!self.pullSuccess) {
                    if ([self.delegate respondsToSelector:@selector(pullScrollViewAccessoryView:endedPullingSuccessfully:)]) {
                        [self.delegate pullScrollViewAccessoryView:self endedPullingSuccessfully:NO];
                    }
                }
                
                self.pullSuccess = NO;
            }
        }
        
        CGFloat startThreshold = 40;
        
        self.arrowView.progress = MAX(0, MIN(1, (offset - startThreshold) / (self.offsetThreshold - startThreshold)));
    }
}

- (void)scrollViewDidEndDragging:(NSNotification *)aNotification
{
    if (self.didBeginPulling) {
        
        self.didBeginPulling = NO;
        self.pullSuccess = [self scrollOffset] >= self.offsetThreshold;
        
                
        if ([self.delegate respondsToSelector:@selector(pullScrollViewAccessoryView:endedPullingSuccessfully:)]) {
            [self.delegate pullScrollViewAccessoryView:self endedPullingSuccessfully:self.pullSuccess];
        }
    }
}

- (void)addToScrollView:(UIScrollView *)scrollView bottom:(BOOL)bottom
{
    self.isBottom = bottom;
    self.parentScrollView = scrollView;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(scrollViewDidEndDragging:) name:FAScrollViewDelegateDidEndDraggingNotification object:scrollView.delegate];
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addSubviewConstraints];
    
    [self.parentScrollView addSubview:self];
    
    NSLayoutConstraint *constraint = nil;
    if (self.isBottom) {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.parentScrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8];
    } else {
        constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.parentScrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-8];
    }
    
    [self.parentScrollView addConstraint:constraint];
    [self.parentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.parentScrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    self.arrowView.upArrow = !bottom;
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
