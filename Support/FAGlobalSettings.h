//
//  FAGlobalSettings.h
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAGlobalSettings : NSObject

+ (instancetype)sharedInstance;

@property (readonly) UIColor *tintColor;
@property BOOL hideCompletedShows;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

@end
