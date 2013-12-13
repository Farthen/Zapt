//
//  FATableViewController.m
//  Zapr
//
//  Created by Finn Wilke on 03/12/13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATableViewController.h"
#import "FARefreshControlWithActivity.h"

@interface FATableViewController ()
@property NSMutableArray *viewDidLoadCompletionBlocks;
@property BOOL viewWasLoaded;

@property (nonatomic, copy) void (^refreshControlWithActivityRefreshDataBlock)(FARefreshControlWithActivity *refreshControl);
@end

@implementation FATableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)setRefreshControlWithActivity:(FARefreshControlWithActivity *)refreshControlWithActivity
{
    self.refreshControl = refreshControlWithActivity;
}

- (FARefreshControlWithActivity *)refreshControlWithActivity
{
    if ([self.refreshControl isKindOfClass:[FARefreshControlWithActivity class]]) {
        return (FARefreshControlWithActivity *)self.refreshControl;
    } else {
        return nil;
    }
}

- (void)refreshControlValueChanged
{
    if (self.refreshControl.refreshing) {
        if ([self refreshControlWithActivityRefreshDataBlock]) {
            self.refreshControlWithActivityRefreshDataBlock(self.refreshControlWithActivity);
        }
    }
}

- (void)setUpRefreshControlWithActivityWithRefreshDataBlock:(void (^)(FARefreshControlWithActivity *refreshControlWithActivity))refreshDataBlock
{
    self.refreshControlWithActivityRefreshDataBlock = refreshDataBlock;
    
    self.refreshControl = [[FARefreshControlWithActivity alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
}

@end
