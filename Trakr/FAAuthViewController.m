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

@interface FAAuthViewController () {
    BOOL _passwordFieldContainsHash;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.introLabel.hidden = NO;
    self.invalidLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameTableViewCell.textField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    NSLog(@"Button pressed");
    self.usernameTextField.userInteractionEnabled = NO;
    self.passwordTextField.userInteractionEnabled = NO;
    [self.loginButtonCell startActivity];
    NSString *username = self.usernameTextField.text;
    NSString *passwordHash;
    if (_passwordFieldContainsHash) {
        passwordHash = [[FATrakt sharedInstance] apiPasswordHash];
    } else {
        passwordHash = [FATrakt passwordHashForPassword:self.passwordTextField.text];
    }
    [[FATrakt sharedInstance] setUsername:username andPasswordHash:passwordHash];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        [self.loginButtonCell finishActivity];
        self.usernameTextField.userInteractionEnabled = YES;
        self.passwordTextField.userInteractionEnabled = YES;
        if (valid) {
            // Clear password text field to remove clear text copy of the password from memory
            self.passwordTextField.text = @"";
            [self dismissModalViewControllerAnimated:YES];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
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
            NSString *username = [[FATrakt sharedInstance] apiUser];
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
            NSString *passwordHash = [[FATrakt sharedInstance] apiPasswordHash];
            if (passwordHash) {
                cell.textField.text = @"*****";
                _passwordFieldContainsHash = YES;
            } else {
                _passwordFieldContainsHash = NO;
            }
        }
        return cell;
    } else {
        FATableViewCellWithActivity *cell = [[FATableViewCellWithActivity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.loginButtonCell = cell;
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    }
}

@end
