//
//  FATextViewController.h
//  Zapr
//
//  Created by Finn Wilke on 16/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FATextViewController : UIViewController

@property IBOutlet UITextView *textView;

- (void)displayBundledFileWithName:(NSString *)fileName;
- (void)displayText:(NSString *)text;

@end
