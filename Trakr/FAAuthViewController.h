//
//  FAAuthViewController.h
//  
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import <UIKit/UIKit.h>
@class FAEditableTableViewCell;

@interface FAAuthViewController : UIViewController  <UITextFieldDelegate, UITableViewDataSource> {
    UIAlertView *passwordAlert;
}

@property IBOutlet FAEditableTableViewCell *usernameTableViewCell;
@property IBOutlet FAEditableTableViewCell *passwordTableViewCell;
@property UITextField *usernameTextField;
@property UITextField *passwordTextField;
@property IBOutlet UILabel *introLabel;
@property IBOutlet UILabel *invalidLabel;
@property IBOutlet UITableViewCell *loginButtonCell;
@property IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loginButtonPressed;
@end
