//
//  FAProgressView.h
//  Zapr
//
//  Created by Finn Wilke on 01.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FAProgressView <NSObject>
@required
@property CGFloat progress;

@optional
@property UILabel *textLabel;
@end
