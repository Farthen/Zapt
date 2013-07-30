//
//  FAContentBookmarkViewController.m
//  Trakr
//
//  Created by Finn Wilke on 30.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAContentBookmarkViewController.h"
#import "FASemiModalEnabledViewController.h"

@interface FAContentBookmarkViewController ()

@end

@implementation FAContentBookmarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    // Make the tableView begin at the very top
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, -30, 0);
}

- (CGSize)preferredContentSize
{
    // Calculate height
    [self.tableView layoutIfNeeded];
    CGSize size = self.tableView.contentSize;
    // UGLY HACK
    size.height -= 66; // This is the automatically applied headers and footers - we don't want them
    return size;
}

- (NSString *)title
{
    return @"Bookmarks";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning1
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

@end
