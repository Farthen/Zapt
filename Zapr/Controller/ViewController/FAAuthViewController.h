//
//  FAAuthViewController.h
//  
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import <UIKit/UIKit.h>
@class FAAuthWindow;
@class FAEditableTableViewCell;
@class FATableViewCellWithActivity;

@interface FAAuthViewController : UIViewController  <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property FAEditableTableViewCell *usernameTableViewCell;
@property FAEditableTableViewCell *passwordTableViewCell;
@property UITextField *usernameTextField;
@property UITextField *passwordTextField;
@property BOOL showsInvalidPrompt;
@property FATableViewCellWithActivity *loginButtonCell;

@property IBOutlet UITableView *tableView;
@property FAAuthWindow *authWindow;

- (void)loginButtonPressed;
@end
