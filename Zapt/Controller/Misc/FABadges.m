//
//  FABadges.m
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FABadges.h"

@interface FABadges ()
@property (weak) UIView *view;
@property NSMutableDictionary *badgeViews;
@end

static NSMapTable *instances;

@implementation FABadges

const NSString *FABadgeWatched = @"BadgeWatched";

typedef enum {
    FABadgePositionUpperLeft,
    FABadgePositionUpperRight
} FABadgePosition;

+ (instancetype)instanceForView:(UIView *)view
{
    FABadges *instance = nil;
    
    @synchronized(self)
    {
        if (!instances) {
            // This collection was chosen so that when the view gets deallocated all stored objects
            // get deallocated too.
            instances = [NSMapTable weakToStrongObjectsMapTable];
        }
        
        instance = [instances objectForKey:view];
        
        if (!instance) {
            instance = [[FABadges alloc] initWithView:view];
            
            if (instance) {
                [instances setObject:instance forKey:view];
            }
        }
    }
    
    return instance;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    
    if (self && view) {
        self.view = view;
        self.badgeViews = [NSMutableDictionary dictionary];
        
        return self;
    }
    
    return nil;
}

+ (FABadgePosition)positionForBadge:(const NSString *)badge
{
    if (badge == FABadgeWatched) {
        return FABadgePositionUpperLeft;
    }
    
    return FABadgePositionUpperRight;
}

+ (CGSize)sizeForBadge:(const NSString *)badge
{
    if (badge == FABadgeWatched) {
        return CGSizeMake(32, 32);
    }
    
    return CGSizeZero;
}

- (void)unbadge:(const NSString *)badge
{
    UIImageView *badgeView = [self.badgeViews objectForKey:badge];
    [badgeView removeFromSuperview];
}

- (void)badge:(const NSString *)badge
{
    UIImageView *badgeView = [self.badgeViews objectForKey:badge];
    
    if (!badgeView) {
        badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[badge copy]]];
        [self.badgeViews setObject:badgeView forKey:badge];
    }
    
    badgeView.frameSize = [self.class sizeForBadge:badge];
    FABadgePosition position = [self.class positionForBadge:badge];
    
    if (position == FABadgePositionUpperLeft) {
        badgeView.frameOrigin = self.view.bounds.origin;
    } else if (position == FABadgePositionUpperRight) {
        badgeView.frameTopPosition = self.view.bounds.origin.y;
        badgeView.frameRightPosition = 0;
    }
    
    [self.view addSubview:badgeView];
}

@end
