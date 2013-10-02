//
//  FAReloadControl.h
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FAReloadControlStateReloading,
    FAReloadControlStateError,
    FAReloadControlStateFinished,
} FAReloadControlState;

@interface FAReloadControl : UIControl

@property FAReloadControlState reloadControlState;

@end
