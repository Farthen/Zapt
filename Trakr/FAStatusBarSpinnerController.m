//
//  FAStatusBarSpinnerController.m
//  Trakr
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAStatusBarSpinnerController.h"

@implementation FAStatusBarSpinnerController {
    NSInteger _startCount;
}

+ (FAStatusBarSpinnerController *)sharedInstance
{
    static dispatch_once_t once;
    static FAStatusBarSpinnerController *controller;
    dispatch_once(&once, ^ { controller = [[FAStatusBarSpinnerController alloc] init]; });
    return controller;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


@end
