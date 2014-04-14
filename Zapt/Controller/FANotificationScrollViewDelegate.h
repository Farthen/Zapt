//
//  FANotificationScrollViewDelegate.h
//  Zapt
//
//  Created by Finn Wilke on 14/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FAScrollViewDelegateNotificationDidScroll;

extern NSString *const FAScrollViewDelegateDidScrollNotification;
extern NSString *const FAScrollViewDelegateWillBeginDraggingNotification;
extern NSString *const FAScrollViewDelegateWillEndDraggingNotification;
extern NSString *const FAScrollViewDelegateDidEndDraggingNotification;
extern NSString *const FAScrollViewDelegateDidScrollToTopNotification;
extern NSString *const FAScrollViewDelegateWillBeginDeceleratingNotification;
extern NSString *const FAScrollViewDelegateDidEndDeceleratingNotification;
extern NSString *const FAScrollViewDelegateWillBeginZoomingNotification;
extern NSString *const FAScrollViewDelegateDidEndZoomingNotification;
extern NSString *const FAScrollViewDelegateDidZoomNotification;
extern NSString *const FAScrollViewDelegateDidEndScrollingAnimationNotification;

extern NSString *const FAScrollViewDelegateUserInfoKeyScrollView;
extern NSString *const FAScrollViewDelegateUserInfoKeyView;

extern NSString *const FAScrollViewDelegateUserInfoKeyVelocity;
extern NSString *const FAScrollViewDelegateUserInfoKeyTargetContentOffset;
extern NSString *const FAScrollViewDelegateUserInfoKeyWillDecelerate;
extern NSString *const FAScrollViewDelegateUserInfoKeyScale;


@interface FANotificationScrollViewDelegate : NSObject <UIScrollViewDelegate>

@property (weak) UIScrollView *scrollView;

@end
