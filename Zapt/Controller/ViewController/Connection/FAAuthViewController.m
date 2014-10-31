//
//  FAAuthViewController.m
//
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import "FAAuthViewController.h"
#import "FAAuthWindow.h"

#import "FATrakt.h"
#import <QuartzCore/QuartzCore.h>
#import "FAEditableTableViewCell.h"
#import "FATableViewCellWithActivity.h"
#import "FAGlobalEventHandler.h"
#import "FAActivityDispatch.h"
#import <OnePasswordExtension.h>

@interface FAAuthViewController () {
    BOOL _passwordFieldContainsHash;
    UITableView *_tableView;
    BOOL _showsInvalidPrompt;
    BOOL _checkingAuth;
    
    BOOL _isSmallScreen;
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
    
    
    // Check if on tinyphone - make some margins smaller if so
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
        height < 568) {
        _isSmallScreen = YES;
    } else {
        _isSmallScreen = NO;
    }
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
    [FAGlobalEventHandler handler].authViewShowing = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.showsInvalidPrompt = NO;
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
    }
    
    return YES;
}

- (void)onePasswordButtonPressed:sender
{
    __weak typeof (self) weakSelf = self;
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"https://trakt.tv" forViewController:self sender:sender completion:^(NSDictionary *loginDict, NSError *error) {
        if (!loginDict) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                DDLogError(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.usernameTextField.text = loginDict[AppExtensionUsernameKey];
        strongSelf.passwordTextField.text = loginDict[AppExtensionPasswordKey];
        [strongSelf.passwordTextField becomeFirstResponder];
    }];
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
    
    [self.loginButtonCell startActivity];
    
    [[FATraktConnection sharedInstance] setUsername:username andPasswordHash:passwordHash];
    [[FATrakt sharedInstance] verifyCredentials:^(BOOL valid) {
        _checkingAuth = NO;
        [self.loginButtonCell finishActivity];
        
        self.usernameTextField.userInteractionEnabled = YES;
        self.passwordTextField.userInteractionEnabled = YES;
        
        if (valid) {
            // Clear password text field to remove clear text copy of the password from memory
            self.passwordTextField.text = @"";
            [self dismiss];
        } else {
            [self.usernameTableViewCell.textField becomeFirstResponder];
            self.showsInvalidPrompt = YES;
            [self.loginButtonCell shakeTextLabelCompletion:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }
    
    if (_isSmallScreen) {
        return 4;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (_isSmallScreen) {
        return 0.01;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Trakt Username & Password", nil);
    }
    
    return nil;
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
            cell.textField.keyboardType = UIKeyboardTypeDefault;
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
            cell.textField.returnKeyType = UIReturnKeySend;
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
        FATableViewCellWithActivity *cell = [[FATableViewCellWithActivity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        cell.textLabel.text = NSLocalizedString(@"Log In", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.loginButtonCell = cell;
        
        return cell;
    }
}

- (void)dismiss
{
    [self.authWindow hideAnimated:YES];
    self.usernameTextField.userInteractionEnabled = NO;
    self.passwordTextField.userInteractionEnabled = NO;
}

- (IBAction)actionCancelButton:(id)sender
{
    [[FATraktConnection sharedInstance] setUsername:nil andPasswordHash:nil];
    [self dismiss];
}

- (BOOL)showsInvalidPrompt
{
    return _showsInvalidPrompt;
}

- (void)setNavigationItem
{
    if (self.showsInvalidPrompt) {
        self.navigationItem.prompt = NSLocalizedString(@"Your credentials are invalid! Please log in again.", nil);
    } else {
        self.navigationItem.prompt = nil;
    }
    
    // Check for 1Password and add button if it is available
    if ([[OnePasswordExtension sharedExtension] isAppExtensionAvailable]) {
        UIBarButtonItem *onePasswordButton = [[UIBarButtonItem alloc] init];
        onePasswordButton.image = [UIImage imageNamed:@"onepassword-navbar"];
        
        onePasswordButton.target = self;
        onePasswordButton.action = @selector(onePasswordButtonPressed:);
        
        self.navigationItem.rightBarButtonItem = onePasswordButton;
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
