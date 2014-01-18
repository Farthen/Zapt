//
//  FABadges.h
//  Zapt
//
//  Created by Finn Wilke on 04/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FABadges : NSObject

extern const NSString *FABadgeWatched;

+ (instancetype)instanceForView:(UIView *)view;

- (void)badge:(const NSString *)badge;
- (void)unbadge:(const NSString *)badge;

@end
