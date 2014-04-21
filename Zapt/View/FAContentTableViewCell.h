//
//  FASearchResultTableViewCell.h
//  Zapt
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FATrakt.h"
#import "FATableViewCellHeight.h"

@interface FAContentTableViewCell : UITableViewCell <FATableViewCellHeight>

+ (CGFloat)cellHeight;

@property BOOL showsProgressForShows;
@property BOOL twoLineMode;
@property (nonatomic) BOOL calendarMode;
@property (nonatomic) BOOL shouldDisplayImage;

@property (nonatomic, retain, readonly) UILabel *leftAuxiliaryTextLabel;
@property (nonatomic) UIImage *image;
@property (nonatomic, readonly) FATraktContent *displayedContent;

- (void)displayContent:(FATraktContent *)content;
- (void)displayContent:(FATraktContent *)content withImage:(UIImage *)image;

@end
