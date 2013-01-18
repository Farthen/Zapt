//
//  FAUIElementWithActivity.h
//  Trakr
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAUIElementWithActivity <NSObject>

@required
- (void)startActivity;  // increments startCount and shows activity indicator
- (void)finishActivity; // decrements startCount and hides activity indicator if 0

@optional
@property (atomic, retain, readwrite) UIActivityIndicatorView *activityIndicatorView;
@property int startCount;
- (void)startActivityWithCount:(NSInteger)count; // increments startcount by count
- (void)stopAllActivity; // Stops all activity no matter what the count was before


@end
