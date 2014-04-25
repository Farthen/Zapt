//
//  FAAuthWindow.m
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAAuthWindow.h"

#import "FAAuthViewController.h"
#import "FAGlobalSettings.h"

@interface FAAuthWindow ()
@property BOOL displayed;
@property (nonatomic, copy) void (^completionHandler)(void);
@end

@implementation FAAuthWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}

+ (instancetype)window
{
    static dispatch_once_t once;
    static FAAuthWindow *window;
    dispatch_once(&once, ^{
        window = [[FAAuthWindow alloc] initWithFrame:[[UIWindow mainWindow] frame]];
        window.tintColor = [FAGlobalSettings sharedInstance].tintColor;
    });
    
    return window;
}

- (CGRect)finalFrame
{
    return [[UIWindow mainWindow] frame];
}

- (CGRect)animationLowFrame
{
    CGRect firstFrame = [self finalFrame];
    firstFrame.origin.y = self.bounds.origin.y + self.bounds.size.height;
    
    return firstFrame;
}

- (void)showIfNeededAnimated:(BOOL)animated withInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt completion:(void (^)(void))completion
{
    BOOL display = NO;
    
    @synchronized(self)
    {
        if (!self.displayed) {
            self.displayed = YES;
            display = YES;
        }
    }
    
    if (display) {
        self.completionHandler = completion;
        
        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        FAAuthViewController *authController = [storyboard instantiateViewControllerWithIdentifier:@"auth"];
        
        authController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        authController.showsInvalidPrompt = showInvalidCredentialsPrompt;
        authController.authWindow = self;
        
        self.windowLevel = UIWindowLevelNormal;
        self.rootViewController = [authController wrapInsideNavigationController];
        
        CGRect finalFrame = [self finalFrame];
        
        self.frame = [self animationLowFrame];
        
        [UIView animateIf:animated duration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self makeKeyAndVisible];
            self.frame = finalFrame;
        } completion:nil];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (self.displayed) {
        CGRect lowFrame = [self animationLowFrame];
        [UIView animateIf:animated duration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = lowFrame;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [[UIWindow mainWindow] makeKeyAndVisible];
            self.displayed = NO;
        }];
        
        if (self.completionHandler) {
            self.completionHandler();
            self.completionHandler = nil;
        }
    }
}

@end
