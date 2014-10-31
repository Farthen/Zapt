//
//  FAEditableTableViewCell.m
//  Zapt
//
//  Created by Finn Wilke on 10.09.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FAEditableTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FAEditableTableViewCell

@synthesize textField = textField;

- (id)init
{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    style = UITableViewCellStyleDefault;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, 280, 23)];
        [self.textLabel removeFromSuperview];
        self.textLabel.hidden = YES;
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textColor = [UIColor blackColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:textField];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:16]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:16]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
        [self.contentView setNeedsLayout];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [self.textField becomeFirstResponder];
    }
}

@end
