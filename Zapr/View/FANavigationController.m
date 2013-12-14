//
//  FANavigationController.m
//  Zapr
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FANavigationController.h"

@interface FANavigationController () {
    UILongPressGestureRecognizer *_longPressGesture;
}

@end

NSString *const FANavigationControllerDidPopToRootViewControllerNotification = @"FATraktActivityNotificationSearch";

@implementation FANavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// stolen from http://stackoverflow.com/a/10005594/1084385
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        // set a default rectangle in case we don't find the back button for some reason
        CGRect rect = CGRectMake(0, 0, 100, 40);
        
        // iterate through the subviews looking for something that looks like it might be the right location to be the back button
        for (UIView *subview in self.navigationBar.subviews) {
            if (subview.frame.origin.x < 30 && subview.frame.size.width < 300 && subview.frame.size.width > 15) {
                rect = subview.frame;
                break;
            }
        }
        
        // ok, let's get the point of the long press
        CGPoint longPressPoint = [sender locationInView:self.navigationBar];
        
        // if the long press point in the rectangle then do whatever
        if (CGRectContainsPoint(rect, longPressPoint)) {
            BOOL pop = YES;
            
            // Check if the delegate wants to have a say in this
            id <FANavigationControllerLongButtonTouchDelegate> __weak delegate = (id <FANavigationControllerLongButtonTouchDelegate> )self.delegate;
            UIViewController *lastViewController = self.viewControllers.lastObject;
            
            if ([self.delegate conformsToProtocol:@protocol(FANavigationControllerLongButtonTouchDelegate)]) {
                if ([delegate respondsToSelector:@selector(navigationController:shouldPopToRootViewControllerAfterLongButtonTouchForViewController:)]) {
                    pop = [delegate navigationController:self shouldPopToRootViewControllerAfterLongButtonTouchForViewController:lastViewController];
                }
            }
            
            if (pop) {
                [self popToRootViewControllerAnimated:YES];
                
                if ([delegate respondsToSelector:@selector(navigationController:didPopToRootViewControllerAfterLongButtonTouchForViewController:)]) {
                    [delegate navigationController:self didPopToRootViewControllerAfterLongButtonTouchForViewController:lastViewController];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FANavigationControllerDidPopToRootViewControllerNotification object:self];
            }
        }
    }
}

- (void)addLongButtonTouchGesture
{
    if (NSClassFromString(@"UILongPressGestureRecognizer")) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGesture.minimumPressDuration = 0.7;
        [self.navigationBar addGestureRecognizer:_longPressGesture];
    }
}

- (void)removeLongButtonTouchGesture
{
    if (_longPressGesture) {
        [self.navigationBar removeGestureRecognizer:_longPressGesture];
        _longPressGesture = nil;
    }
}

- (void)dealloc
{
    [self removeLongButtonTouchGesture];
}

@end
