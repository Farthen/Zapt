//
//  FASimpleControl.m
//  Zapr
//
//  Created by Finn Wilke on 12.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASimpleControl.h"

@interface FASimpleControl ()
@property UIView *highlightView;
@end

@implementation FASimpleControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)checkStateChanged:(UIControlState)oldState
{
    if (!self.highlightView) {
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.backgroundColor = [UIColor blackColor];
        self.highlightView.alpha = 0.4;
        [self addSubview:self.highlightView];
    }
    
    if (self.state != oldState) {
        if (self.state & UIControlStateHighlighted) {
            self.highlightView.frame = self.bounds;
            self.highlightView.hidden = NO;
        } else {
            self.highlightView.hidden = YES;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    UIControlState oldState = self.state;
    [super setHighlighted:highlighted];
    [self checkStateChanged:oldState];
}

- (void)setSelected:(BOOL)selected
{
    UIControlState oldState = self.state;
    [super setSelected:selected];
    [self checkStateChanged:oldState];
}

- (void)setEnabled:(BOOL)enabled
{
    UIControlState oldState = self.state;
    [super setEnabled:enabled];
    [self checkStateChanged:oldState];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIControlState oldState = self.state;
    [super touchesBegan:touches withEvent:event];
    [self checkStateChanged:oldState];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIControlState oldState = self.state;
    [super touchesMoved:touches withEvent:event];
    [self checkStateChanged:oldState];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIControlState oldState = self.state;
    [super touchesEnded:touches withEvent:event];
    [self checkStateChanged:oldState];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIControlState oldState = self.state;
    [super touchesCancelled:touches withEvent:event];
    [self checkStateChanged:oldState];
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    
    if (self.highlightView) {
        self.highlightView.frame = self.bounds;
    }
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
