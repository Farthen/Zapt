//
//  FASemiModalEnabledViewController.m
//  Zapr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASemiModalEnabledViewController.h"
#import "UIView+FrameAdditions.h"
#import "UIView+Animations.h"

@interface FASemiModalEnabledViewController () {
    UIViewController *_presentedSemiModalViewController;
    UIView *_semiModalViewControllerMask;
    NSString *_oldTitle;
    NSArray *_defaultRightBarButtonItems;
    UIViewController *_semiModalParentViewController;
}

@end

@implementation FASemiModalEnabledViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)displaySemiModalViewControllerNavigationItem
{
    // If we have a navigation bar we want to add dismiss options
    if (self.navigationController) {
        _oldTitle = self.navigationItem.title;
        [self.navigationItem setTitle:_presentedSemiModalViewController.title];
        _defaultRightBarButtonItems = self.navigationItem.rightBarButtonItems;
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(semiModalDismissButtonTouched:)] animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
}

- (void)displayContainerNavigationItem
{
    if (self.navigationController) {
        self.navigationItem.title = _oldTitle;
        [self.navigationItem setRightBarButtonItems:_defaultRightBarButtonItems animated:YES];
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (BOOL)presentationStyleDesaturateNavigationBar
{
    if (self.navigationController) {
        return YES;
    }
    return NO;
}

- (void)semiModalDismissGestureFired:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissSemiModalViewControllerAnimated:YES completion:nil];
    }
}

- (void)semiModalDismissButtonTouched:(id)sender
{
    [self dismissSemiModalViewControllerAnimated:YES completion:nil];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if (_presentedSemiModalViewController) {
        return _presentedSemiModalViewController;
    }
    
    return self;
}

- (void)presentSemiModalViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion
{
    // See: http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/CreatingCustomContainerViewControllers/CreatingCustomContainerViewControllers.html
    _presentedSemiModalViewController = viewControllerToPresent;
    
    _semiModalParentViewController = self;
    
    BOOL desaturateNavigationBar = [self presentationStyleDesaturateNavigationBar];
    
    if (desaturateNavigationBar) {
        _semiModalParentViewController = self.navigationController;
    }
    
    
    [_semiModalParentViewController addChildViewController:viewControllerToPresent];
    
    // Create a mask view with semi-black background
    _semiModalViewControllerMask = [[UIView alloc] initWithFrame:_semiModalParentViewController.view.bounds];
    _semiModalViewControllerMask.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    _semiModalViewControllerMask.alpha = 0.0;
    [_semiModalParentViewController.view addSubview:_semiModalViewControllerMask];
    
    // Add a dismiss gesture
    UITapGestureRecognizer *dismissGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(semiModalDismissGestureFired:)];
    [_semiModalViewControllerMask addGestureRecognizer:dismissGestureRecognizer];
    
    // Set the frame to be below the current view
    CGPoint position = CGPointMake(_semiModalParentViewController.view.bounds.origin.x, _semiModalParentViewController.view.bounds.origin.y + _semiModalParentViewController.view.bounds.size.height);
    CGRect viewControllerFrame;
    viewControllerFrame.origin = position;
    viewControllerFrame.size = viewControllerToPresent.view.intrinsicContentSize;
    viewControllerFrame.size.width = _semiModalParentViewController.view.bounds.size.width;
    viewControllerToPresent.view.frame = viewControllerFrame;
    if (viewControllerFrame.size.height <= 0) {
        [self updateSizeForPresentedSemiModalViewControllerAnimated:NO];
    }
    
    // Set the final frame to the viewController moved to the top
    CGRect finalViewControllerFrame = viewControllerToPresent.view.frame;
    finalViewControllerFrame.origin.y = finalViewControllerFrame.origin.y - finalViewControllerFrame.size.height;
    
    // Add it to the view
    [_semiModalParentViewController.view addSubview:viewControllerToPresent.view];
    [viewControllerToPresent didMoveToParentViewController:self];
    
    if (desaturateNavigationBar) {
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    } else {
        [self displaySemiModalViewControllerNavigationItem];
    }
    
    // Animate it up
    [UIView animateIf:animated duration:0.3 animations:^{
        viewControllerToPresent.view.frame = finalViewControllerFrame;
        _semiModalViewControllerMask.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissSemiModalViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if (_presentedSemiModalViewController) {
        [_presentedSemiModalViewController willMoveToParentViewController:nil];
        
        if ([self presentationStyleDesaturateNavigationBar]) {
            self.navigationController.navigationBar.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            [UIApplication sharedApplication].statusBarStyle = self.preferredStatusBarStyle;
        } else {
            [self displayContainerNavigationItem];
        }
        
        [UIView animateIf:animated duration:0.3 animations:^{
            // Set the frame to be below the current view
            
            if (![self presentationStyleDesaturateNavigationBar]) {
                self.navigationItem.title = _oldTitle;
            }
            CGPoint position = CGPointMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.view.bounds.size.height);
            CGRect viewControllerFrame = _presentedSemiModalViewController.view.frame;
            viewControllerFrame.origin = position;
            _presentedSemiModalViewController.view.frame = viewControllerFrame;
            _semiModalViewControllerMask.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_presentedSemiModalViewController.view removeFromSuperview];
            [_presentedSemiModalViewController removeFromParentViewController];
            [_semiModalViewControllerMask removeFromSuperview];
            _semiModalViewControllerMask = nil;
            if (completion) {
                _presentedSemiModalViewController = nil;
                completion();
            }
        }];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self dismissSemiModalViewControllerAnimated:flag completion:completion];
}

- (void)updateSizeForPresentedSemiModalViewControllerAnimated:(BOOL)animated
{
    CGRect frame = _presentedSemiModalViewController.view.frame;
    if ([_presentedSemiModalViewController isKindOfClass:[UITableViewController class]]) {
        CGSize preferredContentSize = _presentedSemiModalViewController.preferredContentSize;
        if (!CGSizeEqualToSize(preferredContentSize, CGSizeZero)) {
            if (preferredContentSize.height < self.view.bounds.size.height) {
                frame.size.height = preferredContentSize.height;
                ((UIScrollView *)(_presentedSemiModalViewController.view)).scrollEnabled = NO;
            } else {
                frame.size.height = self.view.bounds.size.height;
            }
        }
    } else {
        frame.size.height = 100;
    }
    [UIView animateIf:animated duration:0.3 animations:^{
        _presentedSemiModalViewController.view.frame = frame;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self dismissSemiModalViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
