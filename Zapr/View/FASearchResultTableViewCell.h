//
//  FASearchResultTableViewCell.h
//  Zapr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATrakt.h"

@interface FASearchResultTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, retain, readonly) UILabel *leftAuxiliaryTextLabel;

- (void)displayContent:(FATraktContent *)content;

@end
