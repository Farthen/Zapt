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

@interface FAAuthViewController ()

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
    passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Login", nil) message:NSLocalizedString(@"Invalid Trakt username and/or password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Retry", nil) otherButtonTitles: nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activityIndicator.hidden = YES;
    self.loginButtonCell.userInteractionEnabled = YES;
    self.loginButtonCell.textLabel.hidden = NO;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
        return YES;
    } else if (textField == self.passwordTextField) {
        [self loginButtonPressed];
        return YES;
    } return YES;
}

- (void)loginButtonPressed
{
    NSLog(@"Button pressed");
    self.loginButtonCell.userInteractionEnabled = NO;
    self.loginButtonCell.textLabel.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *passwordHash = [FATrakt passwordHashForPassword:password];
    [[FATrakt sharedInstance] setUsername:username andPasswordHash:passwordHash];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid){
        [self.activityIndicator stopAnimating];
        if (valid) {
            [self dismissModalViewControllerAnimated:YES];
        } else {
            NSLog(@"Invalid username/password");
            [passwordAlert show];
            self.activityIndicator.hidden = YES;
            self.loginButtonCell.textLabel.hidden = NO;
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
        } else {
            self.passwordTextField = cell.textField;
            self.passwordTableViewCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Password", nil);
            cell.textField.keyboardType = UIKeyboardTypeDefault;
            cell.textField.secureTextEntry = YES;
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        self.loginButtonCell = cell;
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    }
}

@end
