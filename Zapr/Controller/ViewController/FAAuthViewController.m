//
//  FAAuthViewController.m
//  
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import "FAAuthViewController.h"
#import "FATrakt.h"
#import <QuartzCore/QuartzCore.h>
#import "FAEditableTableViewCell.h"
#import "FATableViewCellWithActivity.h"
#import "FAAppDelegate.h"
#import "FAActivityDispatch.h"

@interface FAAuthViewController () {
    BOOL _passwordFieldContainsHash;
    UITableView *_tableView;
    BOOL _showsInvalidPrompt;
    BOOL _checkingAuth;
}

@end

@implementation FAAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameTableViewCell.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    FAAppDelegate *delegate = (FAAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.authViewShowing = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.passwordTextField && _passwordFieldContainsHash) {
        textField.text = @"";
        _passwordFieldContainsHash = NO;
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
        return YES;
    } else if (textField == self.passwordTextField) {
        [self loginButtonPressed];
        [textField resignFirstResponder];
        return YES;
    } return YES;
}

- (void)loginButtonPressed
{
    DDLogTiny(@"Login Button pressed");
    self.usernameTextField.userInteractionEnabled = NO;
    self.passwordTextField.userInteractionEnabled = NO;
    
    NSString *username = self.usernameTextField.text;
    NSString *passwordHash;
    
    if (_passwordFieldContainsHash) {
        passwordHash = [FATraktConnection sharedInstance].apiPasswordHash;
    } else {
        passwordHash = [FATraktConnection passwordHashForPassword:self.passwordTextField.text];
    }
    
    _checkingAuth = YES;
    
    [[FATraktConnection sharedInstance] setUsername:username andPasswordHash:passwordHash];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        _checkingAuth = NO;
        
        self.usernameTextField.userInteractionEnabled = YES;
        self.passwordTextField.userInteractionEnabled = YES;
        
        if (valid) {
            // Clear password text field to remove clear text copy of the password from memory
            self.passwordTextField.text = @"";
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.usernameTableViewCell.textField becomeFirstResponder];
        }
    }];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0 && !_checkingAuth) {
        [self loginButtonPressed];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Trakt Username & Password", nil);
    } return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FAEditableTableViewCell *cell = [[FAEditableTableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.delegate = self;
        if (indexPath.row == 0) {
            self.usernameTextField = cell.textField;
            self.usernameTableViewCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Username", nil);
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell.textField.returnKeyType = UIReturnKeyNext;
            cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            NSString *username = [[FATraktConnection sharedInstance] apiUser];
            if (username) {
                cell.textField.text = username;
            }
        } else {
            self.passwordTextField = cell.textField;
            self.passwordTableViewCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Password", nil);
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            cell.textField.secureTextEntry = YES;
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            if ([[FATraktConnection sharedInstance] usernameAndPasswordSaved]) {
                cell.textField.text = @"*****";
                _passwordFieldContainsHash = YES;
            } else {
                _passwordFieldContainsHash = NO;
            }
        }
        return cell;
    } else {
        if (self.loginButtonCell) {
            [[FAActivityDispatch sharedInstance] unregister:self.loginButtonCell];
        }
        
        FATableViewCellWithActivity *cell = [[FATableViewCellWithActivity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.loginButtonCell = cell;
        [[FAActivityDispatch sharedInstance] registerForActivityName:FATraktActivityNotificationCheckAuth observer:self.loginButtonCell];
        
        return cell;
    }
}

- (IBAction)actionCancelButton:(id)sender
{
    [[FATraktConnection sharedInstance] setUsername:nil andPasswordHash:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)showsInvalidPrompt
{
    return _showsInvalidPrompt;
}

- (void)setNavigationItem
{
    if (self.showsInvalidPrompt) {
        self.navigationItem.prompt = NSLocalizedString(@"You credentials are invalid! Please log in again.", nil);
    } else {
        self.navigationItem.prompt = nil;
    }
}

- (void)setShowsInvalidPrompt:(BOOL)showsInvalidPrompt
{
    _showsInvalidPrompt = showsInvalidPrompt;
    if (self.navigationController) {
        // viewDidLoad already called, navigation bar available
        [self setNavigationItem];
    }
}

- (void)dealloc
{
    [[FAActivityDispatch sharedInstance] unregister:self.loginButtonCell];
}

@end
