//
//  FACustomListsMembershipViewController.m
//  Zapt
//
//  Created by Finn Wilke on 28.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FACustomListsMembershipViewController.h"
#import "FACustomListsMembershipTableViewController.h"

@interface FACustomListsMembershipViewController ()

@end

@implementation FACustomListsMembershipViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadContent:(FATraktContent *)content
{
    FACustomListsMembershipTableViewController *tableViewController = (FACustomListsMembershipTableViewController *)self.topViewController;
    [tableViewController loadContent:content];
}

@end
