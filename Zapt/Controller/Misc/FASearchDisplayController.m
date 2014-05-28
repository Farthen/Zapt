//
//  FASearchDisplayController.m
//  Zapt
//
//  Created by Finn Wilke on 13/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASearchDisplayController.h"

@implementation FASearchDisplayController

- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController
{
    self = [super initWithSearchBar:searchBar contentsController:viewController];
    
    if (self) {
        self.hidesNavigationBar = YES;
    }
    
    return self;
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive:visible animated:animated];
    
    if (!self.hidesNavigationBar) {
        [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

@end
