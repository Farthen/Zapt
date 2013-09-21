//
//  FARatingsViewController.m
//  Zapr
//
//  Created by Finn Wilke on 12.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FARatingsViewController.h"
#import "UIImage+ImageEffects.h"
#import "FADominantColorsAnalyzer.h"

@interface FARatingsViewController ()
@property UIImage *backgroundImage;
@end

@implementation FARatingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.backgroundImage = nil;
    }
    return self;
}

- (instancetype)initWithBackgroundImageColorsFromImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.backgroundColor = [FADominantColorsAnalyzer dominantColorsOfImage:backgroundImage sampleCount:3][0];
            [self show];
        });
    }
    return self;
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)show
{
    self.view.layer.contents = (__bridge id)(self.backgroundImage.CGImage);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
