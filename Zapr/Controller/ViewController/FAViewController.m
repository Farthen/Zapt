//
//  FAViewController.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAViewController.h"

@interface FAViewController ()
@property NSMutableArray *viewDidLoadCompletionBlocks;
@property BOOL viewWasLoaded;
@end

@implementation FAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
}

- (void)setUp
{
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self performBlock:^{
        self.viewWasLoaded = YES;
        if (self.viewDidLoadCompletionBlocks) {
            for (FAViewControllerCompletionBlock block in self.viewDidLoadCompletionBlocks) {
                block();
            }
            
            self.viewDidLoadCompletionBlocks = nil;
        }
    } afterDelay:0];
}

- (void)dispatchAfterViewDidLoad:(void (^)(void))completionBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.viewWasLoaded) {
            if (!self.viewDidLoadCompletionBlocks) {
                self.viewDidLoadCompletionBlocks = [NSMutableArray array];
            }
            
            [self.viewDidLoadCompletionBlocks addObject:[completionBlock copy]];
        } else {
            completionBlock();
        }
    });
}

@end
