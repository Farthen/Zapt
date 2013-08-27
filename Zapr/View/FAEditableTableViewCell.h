//
//  FAEditableTableViewCell.h
//  Zapr
//
//  Created by Finn Wilke on 10.09.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAEditableTableViewCell : UITableViewCell {
    UITextField *textField;
}

@property (readonly) UITextField *textField;

@end
