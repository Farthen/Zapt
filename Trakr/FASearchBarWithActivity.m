//
//  FASearchBarWithActivity.m
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FASearchBarWithActivity.h"

@implementation FASearchBarWithActivity {
    NSInteger _startCount;
}

@synthesize activityIndicatorView;

- (void)layoutSubviews
{
    UITextField *searchField = nil;
    
    for(UIView* view in self.subviews){
        if([view isKindOfClass:[UITextField class]]){
            searchField= (UITextField *)view;
            break;
        }
    }
    
    if(searchField) {
        if (!self.activityIndicatorView) {
            UIActivityIndicatorView *taiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            taiv.center = CGPointMake(searchField.leftView.bounds.origin.x + searchField.leftView.bounds.size.width/2,
                                      searchField.leftView.bounds.origin.y + searchField.leftView.bounds.size.height/2);
            taiv.hidesWhenStopped = YES;
            taiv.backgroundColor = [UIColor whiteColor];
            self.activityIndicatorView = taiv;
            _startCount = 0;
            
            [searchField.leftView addSubview:self.activityIndicatorView];
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
    _startCount = startCount;
    if (_startCount > 0)
        [self.activityIndicatorView startAnimating];
    else {
        [self.activityIndicatorView stopAnimating];
    }
}

@end
