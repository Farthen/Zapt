//
//  FASlideAnimatedTransition.h
//  Zapt
//
//  Created by Finn Wilke on 13/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FASlideAnimatedTransitionDirection) {
    FASlideAnimatedTransitionDirectionUp = 0,
    FASlideAnimatedTransitionDirectionDown
};

@interface FASlideAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) FASlideAnimatedTransitionDirection direction;

@end
