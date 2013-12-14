//
//  FARefreshControlWithActivity.m
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FARefreshControlWithActivity.h"

@implementation FARefreshControlWithActivity {
    NSInteger _startCount;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        
        self.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@" ", nil)];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.attributedTitle = [[NSAttributedString alloc] initWithString:@" "];
    }
    
    return self;
}

- (void)startActivity
{
    self.startCount += 1;
}

- (void)startActivityWithCount:(NSInteger)count
{
    self.startCount += count;
}

- (void)finishActivity
{
    self.startCount -= 1;
}

- (int)startCount
{
    return _startCount;
}

- (void)setStartCount:(NSInteger)startCount
{
    if (startCount < 0) {
        startCount = 0;
    }
    
    _startCount = startCount;
    
    if (_startCount > 0) {
        if (!self.refreshing) {
            [self beginRefreshing];
        }
        
        self.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Reloading Data…", nil)];
    } else {
        [self endRefreshing];
        self.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@" ", nil)];
    }
}

@end
