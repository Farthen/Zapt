//
//  FASearchBarWithActivity.h
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FASearchBarWithActivity : UISearchBar
{
    UIActivityIndicatorView *activityIndicatorView;
}

@property(retain) UIActivityIndicatorView *activityIndicatorView;
@property int startCount;

- (void)startActivity;  // increments startCount and shows activity indicator
- (void)startActivityWithCount:(NSInteger)count; // increments startcount by count
- (void)finishActivity; // decrements startCount and hides activity indicator if 0

@end
