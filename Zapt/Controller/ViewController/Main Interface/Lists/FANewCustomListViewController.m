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
#import "FASegmentedTableViewCell.h"

#import <FATrakt/FATrakt.h>

@interface FANewCustomListViewController ()

@property (nonatomic) FAEditableTableViewCell *listNameCell;
@property (nonatomic) FAEditableTableViewCell *listDescriptionCell;
@property (nonatomic) FASegmentedTableViewCell *segmentedCell;
@property (nonatomic) UISwitch *showItemNumbersSwitch;
@property (nonatomic) UISwitch *allowShoutsSwitch;

@property (nonatomic) NSInteger selectedPrivacyMode;

@property (nonatomic) FABarButtonItemWithActivity *doneButton;
@property (nonatomic) FAProgressHUD *hud;

@property (nonatomic) FATraktList *editList;

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

- (void)editModeWithList:(FATraktList *)list
{
    self.editList = list;
    self.selectedPrivacyMode = list.privacy;
    self.navigationItem.title = NSLocalizedString(@"Edit List", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    self.doneButton = [[FABarButtonItemWithActivity alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.hud = [[FAProgressHUD alloc] initWithView:self.navigationController.view];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // https://gist.github.com/randomsequence/5728587
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIKeyboardWillShowNotification
                object:nil];
    [nc removeObserver:self
                  name:UIKeyboardWillHideNotification
                object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                         [self.tableView setNeedsDisplay];
                         [self.view setNeedsLayout];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    NSDictionary* info = [aNotification userInfo];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:nil];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction
{
    [self.doneButton startActivity];
    
    NSString *name = self.listNameCell.textField.text;
    
    NSString *description = self.listDescriptionCell.textField.text;
    
    FATraktListPrivacy privacy = self.segmentedCell.segmentedControl.selectedSegmentIndex;
    BOOL ranked = self.showItemNumbersSwitch.isOn;
    BOOL allowShouts = self.allowShoutsSwitch.isOn;
    
    self.view.userInteractionEnabled = NO;
    
    if (!self.editList) {
        [self.hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Adding List", nil)];
        
        [[FATrakt sharedInstance] addNewCustomListWithName:name
                                               description:description
                                                   privacy:privacy
                                                    ranked:ranked
                                               allowShouts:allowShouts
                                                  callback:^{
                                                      [self.hud showProgressHUDSuccessMessage:NSLocalizedString(@"Success", nil)];
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  } onError:^(FATraktConnectionResponse *connectionError) {
                                                      [self.hud showProgressHUDFailedMessage:NSLocalizedString(@"Failed", nil)];
                                                      [self.doneButton finishActivity];
                                                      self.view.userInteractionEnabled = YES;
                                                  }];
    } else {
        
        // Editing a list
        [self.hud showProgressHUDSpinnerWithText:NSLocalizedString(@"Updating List", nil)];
        
        [[FATrakt sharedInstance] editCustomList:self.editList
                                         newName:self.listNameCell.textField.text
                                     description:description
                                         privacy:self.segmentedCell.segmentedControl.selectedSegmentIndex
                                          ranked:self.showItemNumbersSwitch.isOn
                                     allowShouts:self.allowShoutsSwitch.isOn
                                        callback:^{
                                            self.editList.name = name;
                                            self.editList.list_description = description;
                                            self.editList.privacy = privacy;
                                            self.editList.show_numbers = ranked;
                                            self.editList.allow_shouts = allowShouts;
                                            [self.editList updateTimestamp];
                                            [self.editList commitToCache];
                                            
                                            [self.hud showProgressHUDSuccessMessage:NSLocalizedString(@"Success", nil)];
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        } onError:^(FATraktConnectionResponse *connectionError) {
                                            [self.hud showProgressHUDFailedMessage:NSLocalizedString(@"Failed", nil)];
                                            [self.doneButton finishActivity];
                                            self.view.userInteractionEnabled = YES;
                                        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"List", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Privacy", nil);
    }
    
    return nil;
}

- (void)listNameValueChanged:(UIEvent *)event
{
    if (self.listNameCell.textField.text && ![self.listNameCell.textField.text isEqual:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)segmentedControlValueChanged:(UIEvent *)event
{
    self.selectedPrivacyMode = self.segmentedCell.segmentedControl.selectedSegmentIndex;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        switch (self.segmentedCell.segmentedControl.selectedSegmentIndex) {
            case 0:
                return NSLocalizedString(@"The list is only visible to you", nil);
            case 1:
                return NSLocalizedString(@"The list is visible to you and friends", nil);
            case 2:
                return NSLocalizedString(@"The list is visible to anyone", nil);
            default:
                return nil;
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView = tableView;
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        FAEditableTableViewCell *editableCell = [[FAEditableTableViewCell alloc] init];
        cell = editableCell;
        editableCell.selectionStyle = UITableViewCellSelectionStyleNone;
        editableCell.textField.delegate = self;
        
        if (indexPath.row == 0) {
            self.listNameCell = editableCell;
            editableCell.textField.placeholder = NSLocalizedString(@"List Name", nil);
            editableCell.textField.keyboardType = UIKeyboardTypeDefault;
            editableCell.textField.returnKeyType = UIReturnKeyNext;
            editableCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            editableCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editableCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            [editableCell.textField addTarget:self action:@selector(listNameValueChanged:) forControlEvents:UIControlEventEditingChanged];
            
            if (self.editList) {
                editableCell.textField.text = self.editList.name;
                [self listNameValueChanged:nil];
            }
        } else if (indexPath.row == 1) {
            self.listDescriptionCell = editableCell;
            editableCell.textField.placeholder = NSLocalizedString(@"Description (optional)", nil);
            editableCell.textField.keyboardType = UIKeyboardTypeDefault;
            editableCell.textField.returnKeyType = UIReturnKeyDefault;
            editableCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            editableCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            editableCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            if (self.editList) {
                editableCell.textField.text = self.editList.list_description;
            }
        }
        
    } else if (indexPath.section == 1) {
        
        self.segmentedCell = [[FASegmentedTableViewCell alloc] init];
        cell = self.segmentedCell;
        [self.segmentedCell.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.segmentedCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"Private", nil) atIndex:0 animated:NO];
        [self.segmentedCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"Friends", nil) atIndex:1 animated:NO];
        [self.segmentedCell.segmentedControl insertSegmentWithTitle:NSLocalizedString(@"Public", nil) atIndex:2 animated:NO];
        
        self.segmentedCell.segmentedControl.selectedSegmentIndex = self.selectedPrivacyMode;
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            self.showItemNumbersSwitch = [[UISwitch alloc] init];
            cell.accessoryView = self.showItemNumbersSwitch;
            
            cell.textLabel.text = NSLocalizedString(@"Show item numbers", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Can be used to create ranked lists", nil);
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            
            if (self.editList) {
                self.showItemNumbersSwitch.on = self.editList.show_numbers;
            }
        } else if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            
            self.allowShoutsSwitch = [[UISwitch alloc] init];
            cell.accessoryView = self.allowShoutsSwitch;
            
            cell.textLabel.text = NSLocalizedString(@"Allow discussion", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Allows users to comment on the list", nil);
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            
            if (self.editList) {
                self.allowShoutsSwitch.on = self.editList.allow_shouts;
            }
        }
        
    }
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.listNameCell.textField) {
        [self.listDescriptionCell.textField becomeFirstResponder];
        
        return YES;
    } else if (textField == self.listDescriptionCell.textField) {
        [textField resignFirstResponder];
        
        return YES;
    }
    
    return NO;
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
