//
//  FASearchBarWithActivity.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchBarWithActivity.h"
#import "FAStatusBarSpinnerController.h"

@implementation FASearchBarWithActivity {
    NSInteger _startCount;
    UIView *_oldLeftView;
    UITextField *__searchField;
}

@synthesize activityIndicatorView;

- (void)layoutSubviews
{    
    if (!__searchField) {
        for(UIView* view in self.subviews){
            if([view isKindOfClass:[UITextField class]]){
                __searchField= (UITextField *)view;
                break;
            }
        }
    }
    
    if (!_oldLeftView) {
        _oldLeftView = __searchField.leftView;
    }
    
    if(__searchField) {
        if (!self.activityIndicatorView) {
            UIActivityIndicatorView *taiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            taiv.center = CGPointMake(__searchField.leftView.bounds.origin.x + __searchField.leftView.bounds.size.width/2, __searchField.leftView.bounds.origin.y + __searchField.leftView.bounds.size.height/2);
            taiv.hidesWhenStopped = NO;
            taiv.frame = _oldLeftView.frame;
            taiv.backgroundColor = [UIColor clearColor];
            self.activityIndicatorView = taiv;
            _startCount = 0;
        }
    }
    
    [super layoutSubviews];
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
    NSInteger difference = startCount - _startCount;
    [FAStatusBarSpinnerController sharedInstance].startCount += difference;
    _startCount = startCount;
    if (_startCount > 0) {
        [self.activityIndicatorView startAnimating];
        __searchField.leftView = self.activityIndicatorView;
    } else {
        [self.activityIndicatorView stopAnimating];
        __searchField.leftView = _oldLeftView;
    }
}

@end
