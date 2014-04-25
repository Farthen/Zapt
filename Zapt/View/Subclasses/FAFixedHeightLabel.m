//
//  FAFixedHeightLabel.m
//  Zapt
//
//  Created by Finn Wilke on 12.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAFixedHeightLabel.h"

@implementation FAFixedHeightLabel

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
    NSString *oldText = self.text;
    NSMutableString *newlineText = [[NSMutableString alloc] initWithString:@" "];
    
    for (NSInteger i = 1; i < self.numberOfLines; i++) {
        [newlineText appendString:@"\n "];
    }
    
    CGSize normalIntrinsicSize = [super intrinsicContentSize];
    
    self.text = newlineText;
    
    CGSize newlineIntrinsicSize = [super intrinsicContentSize];
    
    self.text = oldText;
    
    CGSize intrinsicSize = CGSizeMake(normalIntrinsicSize.width, newlineIntrinsicSize.height);
    
    return intrinsicSize;
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
