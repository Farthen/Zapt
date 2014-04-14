//
//  FANotificationScrollViewDelegate.m
//  Zapt
//
//  Created by Finn Wilke on 14/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FANotificationScrollViewDelegate.h"

NSString *const FAScrollViewDelegateDidScrollNotification               = @"FAScrollViewDelegateDidScrollNotification";
NSString *const FAScrollViewDelegateWillBeginDraggingNotification       = @"FAScrollViewDelegateWillBeginDraggingNotification";
NSString *const FAScrollViewDelegateWillEndDraggingNotification         = @"FAScrollViewDelegateWillEndDraggingNotification";
NSString *const FAScrollViewDelegateDidEndDraggingNotification          = @"FAScrollViewDelegateDidEndDraggingNotification";
NSString *const FAScrollViewDelegateDidScrollToTopNotification          = @"FAScrollViewDelegateDidScrollToTopNotification";
NSString *const FAScrollViewDelegateWillBeginDeceleratingNotification   = @"FAScrollViewDelegateWillBeginDeceleratingNotification";
NSString *const FAScrollViewDelegateDidEndDeceleratingNotification      = @"FAScrollViewDelegateDidEndDeceleratingNotification";
NSString *const FAScrollViewDelegateWillBeginZoomingNotification        = @"FAScrollViewDelegateWillBeginZoomingNotification";
NSString *const FAScrollViewDelegateDidEndZoomingNotification           = @"FAScrollViewDelegateDidEndZoomingNotification";
NSString *const FAScrollViewDelegateDidZoomNotification                 = @"FAScrollViewDelegateDidZoomNotification";
NSString *const FAScrollViewDelegateDidEndScrollingAnimationNotification= @"FAScrollViewDelegateDidEndScrollingAnimationNotification";

NSString *const FAScrollViewDelegateUserInfoKeyScrollView          = @"scrollView";
NSString *const FAScrollViewDelegateUserInfoKeyView                = @"view";

NSString *const FAScrollViewDelegateUserInfoKeyVelocity            = @"velocity";
NSString *const FAScrollViewDelegateUserInfoKeyTargetContentOffset = @"targetContentOffset";
NSString *const FAScrollViewDelegateUserInfoKeyWillDecelerate      = @"willDecelerate";
NSString *const FAScrollViewDelegateUserInfoKeyScale               = @"scale";

@interface FANotificationScrollViewDelegate()
@property (nonatomic) NSNotificationCenter *notificationCenter;
@end

@implementation FANotificationScrollViewDelegate

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.notificationCenter = [NSNotificationCenter defaultCenter];
    }
    
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidScrollNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateWillBeginDraggingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateWillEndDraggingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView,
        FAScrollViewDelegateUserInfoKeyVelocity: [NSValue valueWithCGPoint:velocity],
        FAScrollViewDelegateUserInfoKeyTargetContentOffset: [NSValue valueWithCGPoint:*targetContentOffset]
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidEndDraggingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView,
        FAScrollViewDelegateUserInfoKeyWillDecelerate: [NSNumber numberWithBool:decelerate]
    }];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidScrollToTopNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateWillBeginDeceleratingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidEndDeceleratingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateWillBeginZoomingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView,
        FAScrollViewDelegateUserInfoKeyView: view
    }];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidEndZoomingNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView,
        FAScrollViewDelegateUserInfoKeyView: view,
        FAScrollViewDelegateUserInfoKeyScale: [NSNumber numberWithFloat:scale]
    }];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidZoomNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.notificationCenter postNotificationName:FAScrollViewDelegateDidEndScrollingAnimationNotification object:self userInfo:@{
        FAScrollViewDelegateUserInfoKeyScrollView: scrollView
    }];
}

@end
