//
//  FARefreshControlWithActivity.m
//  Trakr
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

- (void)setStartCount:(NSInteger)startCount {
    _startCount = startCount;
    if (_startCount > 0) {
        if (self.refreshing) {
            [self beginRefreshing];
        }
    } else {
        [self endRefreshing];
    }
}


@end
