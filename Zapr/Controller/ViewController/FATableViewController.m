//
//  FATableViewController.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"

@interface FATableViewController ()
@property NSMutableArray *viewDidLoadCompletionBlocks;
@property BOOL viewWasLoaded;
@end

@implementation FATableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
