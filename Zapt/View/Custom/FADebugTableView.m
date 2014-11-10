//
//  FADebugTableView.m
//  Zapt
//
//  Created by Finn Wilke on 11.10.14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FADebugTableView.h"

@implementation FADebugTableView

- (void)setContentOffset:(CGPoint)contentOffset
{
    NSLog(@"Setting content offset. Old value: x:%f, y:%f. New value: x:%f, y:%f\n", self.contentOffset.x, self.contentOffset.y, contentOffset.x, contentOffset.y);
    [super setContentOffset:contentOffset];
}

- (void)setContentSize:(CGSize)contentSize
{
    NSLog(@"Setting content size. Old value: width:%f, height:%f. New value: width:%f, height:%f\n", self.contentSize.width, self.contentSize.height, contentSize.width, contentSize.height);
    [super setContentSize:contentSize];
}

@end
