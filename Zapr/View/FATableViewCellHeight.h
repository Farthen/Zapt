//
//  FATableViewCellHeight.h
//  Zapr
//
//  Created by Finn Wilke on 07/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FATableViewCellHeight <NSObject>

@optional
+ (CGFloat)cellHeight;
+ (CGFloat)cellHeightForObject:(id)object;

@end
