//
//  FATextViewController.m
//  Zapt
//
//  Created by Finn Wilke on 16/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATextViewController.h"

@interface FATextViewController ()
@property NSString *text;
@end

@implementation FATextViewController

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
    
    self.textView.text = self.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayText:(NSString *)text
{
    self.text = text;
    self.textView.text = text;
}

- (void)displayBundledFileWithName:(NSString *)fileName
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:fileName ofType:@"txt"];
    NSString *text = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self displayText:text];
}

@end
