//
//  FAPushoverViewAnimationController.h
//  Zapr
//
//  Created by Finn Wilke on 25.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAPushoverView.h"
@class FAMaskingView;
@class FATitleLabel;

@interface FAPushoverViewAnimationController : NSObject <FAPushoverViewDelegate>

- (instancetype) initWithPushoverView:(FAPushoverView *)pushoverView maskingView:(FAMaskingView *)maskingView titleLabel:(FATitleLabel *)titleLabel titleLabelConstraint:(NSLayoutConstraint *)titleLabelConstraint;

@end
