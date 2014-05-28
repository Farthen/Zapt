//
//  FAViewController.h
//  Zapt
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAViewController : UIViewController

- (void)setUp;

typedef void (^FAViewControllerCompletionBlock)(void);
- (void)dispatchAfterViewDidLoad:(void (^)(void))completionBlock;

@end
