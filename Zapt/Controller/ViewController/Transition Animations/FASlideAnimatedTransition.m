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
    
    fromView.frame = fromViewController.view.frame;
    //[fromViewController.view removeFromSuperview];
    [containerView addSubview:fromView];
    
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
            toToolbar.frame = [toViewController.navigationController.toolbar.superview convertRect:toViewController.navigationController.toolbar.frame toView:toToolbar.superview];
            toViewController.navigationController.toolbarHidden = YES;
            
            toView.userInteractionEnabled = YES;
            
            [toolbarScreenshot removeFromSuperview];
        }];
        
        toViewController.navigationController.interactivePopGestureRecognizer.enabled = interactivePopGesture;
        
        [transitionContext completeTransition:YES];
    };
    
    CGFloat finalTopPosition = toView.frameTopPosition;
    CGFloat finalBottomPosition = toView.frameBottomPosition;
    
    if (self.direction == FASlideAnimatedTransitionDirectionUp) {
        toView.frameTopPosition = finalBottomPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frameBottomPosition = finalTopPosition;
            toView.frameTopPosition = finalTopPosition;
        } completion:completionBlock];
    } else {
        toView.frameBottomPosition = finalTopPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.frameTopPosition = finalBottomPosition;
            toView.frameTopPosition = finalTopPosition;
        } completion:completionBlock];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

@end
