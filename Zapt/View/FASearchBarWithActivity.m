//
//  FASearchBarWithActivity.m
//  Zapt
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchBarWithActivity.h"
#import "FAStatusBarSpinnerController.h"
#import "Misc.h"

@implementation FASearchBarWithActivity {
    NSInteger _startCount;
    UIView *_oldLeftView;
    id __searchField;
    UIImage *_oldImage;
}

@synthesize activityIndicatorView;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (!_oldLeftView) {
            for (UIView *view in[self recursiveSubviews]) {
                if ([view isKindOfClass:[UITextField class]] && [view respondsToSelector:@selector(leftView)]) {
                    __searchField = view;
                    _oldLeftView = [(UITextField *)view leftView];
                    break;
                }
            }
        }
    } else {
        if (!__searchField) {
            for (UIView *view in self.subviews) {
                if ([view isKindOfClass:[UITextField class]]) {
                    __searchField = (UITextField *)view;
                    break;
                }
            }
        }
        
        if (!_oldLeftView) {
            _oldLeftView = ((UITextField *)__searchField).leftView;
        }
    }
    
    if (_oldLeftView) {
        if (!self.activityIndicatorView) {
            UIActivityIndicatorView *taiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGRect bounds = _oldLeftView.bounds;
            taiv.center = CGPointMake(bounds.origin.x + bounds.size.width / 2, bounds.origin.y + bounds.size.height / 2);
            taiv.hidesWhenStopped = NO;
            taiv.backgroundColor = [UIColor clearColor];
            self.activityIndicatorView = taiv;
            _startCount = 0;
        }
    }
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
    
    NSInteger difference = startCount - _startCount;
    [FAStatusBarSpinnerController sharedInstance].startCount += difference;
    _startCount = startCount;
    
    if (_startCount > 0) {
        [self.activityIndicatorView startAnimating];
        
        if ([__searchField isKindOfClass:[UITextField class]]) {
            [self setImage:[[UIImage alloc] init] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
            [((UITextField *)__searchField).leftView addSubview : self.activityIndicatorView];
        }
    } else {
        [self.activityIndicatorView stopAnimating];
        
        if ([__searchField isKindOfClass:[UITextField class]]) {
            [self setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
            [self.activityIndicatorView removeFromSuperview];
        }
    }
}

@end
