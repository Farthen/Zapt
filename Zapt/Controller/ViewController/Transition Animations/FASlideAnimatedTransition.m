//
//  FASlideAnimatedTransition.m
//  Zapt
//
//  Created by Finn Wilke on 13/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FASlideAnimatedTransition.h"

@implementation FASlideAnimatedTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIToolbar *fromToolbar = [fromViewController toolbarView];
    UIToolbar *toToolbar = [toViewController toolbarView];
    
    BOOL interactivePopGesture = toViewController.navigationController.interactivePopGestureRecognizer.enabled;
    
    // screenshot of the toolbar without the background
    UIView *toolbarScreenshot = [fromToolbar snapshotViewAfterScreenUpdates:NO];
    
    if (fromToolbar && toToolbar) {
        
        [UIView performWithoutAnimation:^{
            fromToolbar.hidden = YES;
            toToolbar.hidden = YES;
            toolbarScreenshot.frameBottomPosition = containerView.boundsBottomPosition;
            
            // draw the toolbar background
            toViewController.navigationController.toolbarHidden = NO;
            
            [toViewController.navigationController.view setNeedsLayout];
            [toViewController.navigationController.view layoutIfNeeded];
        }];
    }
    
    __block UIView *fromView = nil;
    
    [UIView performWithoutAnimation:^{
        fromView = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
    }];
    
    UIView *toView = toViewController.view;
    
    //fromViewController.view.hidden = YES;
    fromViewController.view.userInteractionEnabled = NO;
    
    [UIView performWithoutAnimation:^{
        [containerView addSubview:fromView];
        [containerView insertSubview:toView aboveSubview:fromView];
        
        if (toolbarScreenshot) {
            toolbarScreenshot.frameBottomPosition = toViewController.navigationController.toolbar.boundsBottomPosition;
            [toViewController.navigationController.toolbar addSubview:toolbarScreenshot];
        }
    }];
    
    fromView.userInteractionEnabled = NO;
    toView.userInteractionEnabled = NO;
    
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
        [UIView performWithoutAnimation:^{
            toToolbar.hidden = NO;
            toViewController.navigationController.toolbarHidden = YES;
            
            toView.userInteractionEnabled = YES;
            
            [toolbarScreenshot removeFromSuperview];
        }];
        
        toViewController.navigationController.interactivePopGestureRecognizer.enabled = interactivePopGesture;
        
        [transitionContext completeTransition:YES];
    };
    
    if (self.direction == FASlideAnimatedTransitionDirectionUp) {
        fromView.frameTopPosition = containerView.boundsTopPosition;
        toView.frameTopPosition = containerView.boundsBottomPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frameBottomPosition = containerView.boundsTopPosition;
            toView.frameTopPosition = containerView.boundsTopPosition;
        } completion:completionBlock];
    } else {
        toView.frameBottomPosition = containerView.frameTopPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frameTopPosition = containerView.frameBottomPosition;
            toView.frameBottomPosition = containerView.frameBottomPosition;
        } completion:completionBlock];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

@end
