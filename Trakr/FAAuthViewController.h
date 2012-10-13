//
//  FAAuthViewController.h
//  
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import <UIKit/UIKit.h>
@class FAEditableTableViewCell;
@class FATableViewCellWithActivity;

@interface FAAuthViewController : UIViewController  <UITextFieldDelegate, UITableViewDataSource>

@property FAEditableTableViewCell *usernameTableViewCell;
@property FAEditableTableViewCell *passwordTableViewCell;
@property UITextField *usernameTextField;
@property UITextField *passwordTextField;
@property IBOutlet UILabel *introLabel;
@property IBOutlet UILabel *invalidLabel;
@property FATableViewCellWithActivity *loginButtonCell;

- (void)loginButtonPressed;
@end
