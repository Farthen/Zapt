//
//  FATableViewCellWithActivity.h
//  Zapt
//
//  Created by Finn Wilke on 13.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAUIElementWithActivity.h"

@interface FATableViewCellWithActivity : UITableViewCell <FAUIElementWithActivity>

- (void)shakeTextLabelCompletion:(void (^)(void))completion;

@end
