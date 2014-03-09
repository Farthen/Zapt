//
//  FANewCustomListViewController.m
//  Zapt
//
//  Created by Finn Wilke on 09/03/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FANewCustomListViewController.h"
#import "FAEditableTableViewCell.h"
#import "FATableViewCellWithActivity.h"
#import "FABarButtonItemWithActivity.h"
#import "FAProgressHUD.h"

#import "FATrakt.h"

@interface FANewCustomListViewController ()

@property (nonatomic) UITextField *listNameTextField;
@property (nonatomic) FABarButtonItemWithActivity *doneButton;
@property (nonatomic) FAProgressHUD *hud;

@end

@implementation FANewCustomListViewController

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
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.doneButton = [[FABarButtonItemWithActivity alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    self.hud = [[FAProgressHUD alloc] initWithView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction
{
    [self.doneButton startActivity];
    [self.hud showProgressHUDSpinnerWithText:@"Adding List"];
    
    [[FATrakt sharedInstance] addNewCustomListWithName:self.listNameTextField.text description:nil privacy:FATraktListPrivacyPrivate ranked:NO allowShouts:NO callback:^{
        [self.hud showProgressHUDSuccessMessage:NSLocalizedString(@"Success", nil)];
        [self dismissViewControllerAnimated:YES completion:nil];
    } onError:^(FATraktConnectionResponse *connectionError) {
        [self.hud showProgressHUDFailedMessage:NSLocalizedString(@"Failed", nil)];
        [self.doneButton stopAllActivity];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        FAEditableTableViewCell *editableCell = [[FAEditableTableViewCell alloc] init];
        cell = editableCell;
        editableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        editableCell.textField.delegate = self;
        
        if (indexPath.row == 0) {
            self.listNameTextField = editableCell.textField;
            editableCell.textField.placeholder = NSLocalizedString(@"List Name", nil);
            editableCell.textField.keyboardType = UIKeyboardTypeDefault;
            editableCell.textField.returnKeyType = UIReturnKeyNext;
            editableCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            editableCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editableCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        }
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
