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
    DDLogController(@"Starting activity");
    self.startCount += 1;
}

- (void)startActivityWithCount:(NSInteger)count
{
    self.startCount += count;
}

- (void)finishActivity
{
    DDLogController(@"Stopping activity");
    self.startCount -= 1;
}

- (void)stopAllActivity
{
    self.startCount = 0;
}

- (int)startCount
{
    return _startCount;
}

- (void)setStartCount:(NSInteger)startCount {
    if (startCount < 0) {
        startCount = 0;
    }
    _startCount = startCount;
    if (_startCount > 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}


@end
