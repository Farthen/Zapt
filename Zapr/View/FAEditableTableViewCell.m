//
//  FAEditableTableViewCell.m
//  Zapr
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
        
        [self.contentView addSubview:textField];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
