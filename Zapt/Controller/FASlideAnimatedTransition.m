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
    
    [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    fromViewController.view.userInteractionEnabled = NO;
    toViewController.view.userInteractionEnabled = NO;
    
    if (self.direction == FASlideAnimatedTransitionDirectionUp) {
        toViewController.view.frameTopPosition = containerView.frameBottomPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frameBottomPosition = containerView.frameTopPosition;
            toViewController.view.frameTopPosition = containerView.frameTopPosition;
        } completion:^(BOOL finished) {
            toViewController.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    } else {
        toViewController.view.frameBottomPosition = containerView.frameTopPosition;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frameTopPosition = containerView.frameBottomPosition;
            toViewController.view.frameBottomPosition = containerView.frameBottomPosition;
        } completion:^(BOOL finished) {
            toViewController.view.userInteractionEnabled = YES;
            [transitionContext completeTransition:YES];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

@end
